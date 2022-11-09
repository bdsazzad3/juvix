module Internal.Eval.Base where

import Base
import Core.Eval.Base
import Data.HashMap.Strict qualified as HashMap
import Data.Text.IO qualified as TIO
import Juvix.Compiler.Builtins (iniState)
import Juvix.Compiler.Core.Data.InfoTable
import Juvix.Compiler.Core.Extra
import Juvix.Compiler.Core.Info qualified as Info
import Juvix.Compiler.Core.Info.NoDisplayInfo
import Juvix.Compiler.Core.Pretty
import Juvix.Compiler.Core.Translation.FromInternal.Data as Core
import Juvix.Compiler.Pipeline
import System.IO.Extra (withTempDir)

internalCoreAssertion :: FilePath -> FilePath -> (String -> IO ()) -> Assertion
internalCoreAssertion mainFile expectedFile step = do
  step "Translate to Core"
  let entryPoint = defaultEntryPoint mainFile
  tab <- (^. Core.coreResultTable) . snd <$> runIO' iniState entryPoint upToCore
  case (tab ^. infoMain) >>= ((tab ^. identContext) HashMap.!?) of
    Just node -> do
      withTempDir
        ( \dirPath -> do
            let outputFile = dirPath </> "out.out"
            hout <- openFile outputFile WriteMode
            step "Evaluate"
            r' <- doEval mainFile hout tab node
            case r' of
              Left err -> do
                hClose hout
                assertFailure (show (pretty err))
              Right value -> do
                unless
                  (Info.member kNoDisplayInfo (getInfo value))
                  (hPutStrLn hout (ppPrint value))
                hClose hout
                actualOutput <- TIO.readFile outputFile
                step "Compare expected and actual program output"
                expected <- TIO.readFile expectedFile
                assertEqDiff ("Check: EVAL output = " <> expectedFile) actualOutput expected
        )
    Nothing -> assertFailure ("No main function registered in: " <> mainFile)