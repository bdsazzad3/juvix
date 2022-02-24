module MiniJuvix.Termination.CallGraph (
module MiniJuvix.Termination.CallGraph.Types ,
module MiniJuvix.Termination.CallGraph
                                       ) where

import MiniJuvix.Prelude
import MiniJuvix.Syntax.Abstract.Language.Extra
import qualified Data.HashMap.Strict as HashMap
import MiniJuvix.Termination.CallGraph.Types


-- | i = SizeInfo [v] ⇔ v is smaller than argument i of the caller function.
-- Indexes are 0 based
type SizeInfo = HashMap VarName Int

viewCall :: Members '[Reader SizeInfo] r
   => Expression -> Sem r (Maybe Call)
viewCall e = case e of
  ExpressionApplication (Application f x) -> do
    c <- viewCall f
    x' <- callArg
    return $ over callArgs (`snoc`x') <$> c
    where
     callArg = case x of
       ExpressionIden (IdenVar v) -> do
         s <- asks (HashMap.lookup v)
         return (s, x)
       _ -> return (Nothing, x)

  ExpressionIden (IdenDefined x) ->
     return (Just (singletonCall x))
  _ -> return Nothing
  where
  singletonCall :: Name -> Call
  singletonCall n = Call n []

addCall :: FunctionName -> Call -> CallGraph -> CallGraph
addCall fun c = over callGraph (HashMap.insertWith (flip (<>)) fun [c])

registerCall :: Members '[State CallGraph, Reader FunctionName, Reader SizeInfo] r
   => Call -> Sem r ()
registerCall c = do
  fun <- ask
  modify (addCall fun c)

buildCallGraph :: TopModule -> CallGraph
buildCallGraph = run . execState mempty . checkModule

checkModule :: Members '[State CallGraph] r => TopModule -> Sem r ()
checkModule m = checkModuleBody (m ^. moduleBody)

checkModuleBody :: Members '[State CallGraph] r => ModuleBody -> Sem r ()
checkModuleBody body = do
  mapM_ checkFunctionDef (toList $ body ^. moduleFunctions)
  mapM_ checkLocalModule (toList $ body ^. moduleLocalModules)

checkLocalModule :: Members '[State CallGraph] r => LocalModule -> Sem r ()
checkLocalModule m = checkModuleBody (m ^. moduleBody)

checkFunctionDef :: Members '[State CallGraph] r => FunctionDef -> Sem r ()
checkFunctionDef def = runReader (def ^. funDefName) $ do
  checkTypeSignature (def ^. funDefTypeSig)
  mapM_ checkFunctionClause (def ^. funDefClauses)

checkTypeSignature :: Members '[State CallGraph, Reader FunctionName] r => Expression -> Sem r ()
checkTypeSignature = runReader (mempty :: SizeInfo) . checkExpression

mkSizeInfo :: [Pattern] -> SizeInfo
mkSizeInfo ps = HashMap.fromList
  [ (v, i) | (i, p) <- zip [0..] ps,
    v <- smallerPatternVariables p]

checkFunctionClause :: Members '[State CallGraph, Reader FunctionName] r =>
  FunctionClause -> Sem r ()
checkFunctionClause cl = runReader (mkSizeInfo (cl ^. clausePatterns))
  $ checkExpression (cl ^. clauseBody)

checkExpression :: Members '[State CallGraph, Reader FunctionName, Reader SizeInfo] r => Expression -> Sem r ()
checkExpression e = do
  mc <- viewCall e
  case mc of
    Just c -> do registerCall c
                 mapM_ (checkExpression . snd) (c ^. callArgs)
    Nothing -> case e of
      ExpressionApplication a -> checkApplication a
      ExpressionIden {} -> return ()
      ExpressionUniverse {} -> return ()
      ExpressionFunction f -> checkFunction f

checkApplication :: Members '[State CallGraph, Reader FunctionName, Reader SizeInfo] r
  => Application -> Sem r ()
checkApplication (Application l r) = do
  checkExpression l
  checkExpression r

checkFunction :: Members '[State CallGraph, Reader FunctionName, Reader SizeInfo] r
  => Function -> Sem r ()
checkFunction (Function l r) = do
  checkFunctionParameter l
  checkExpression r

checkFunctionParameter :: Members '[State CallGraph, Reader FunctionName, Reader SizeInfo] r
   => FunctionParameter -> Sem r ()
checkFunctionParameter p = checkExpression (p ^. paramType)
