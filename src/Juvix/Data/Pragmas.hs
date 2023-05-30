module Juvix.Data.Pragmas where

import Data.Aeson.BetterErrors qualified as Aeson
import Juvix.Data.Yaml
import Juvix.Prelude.Base

data PragmaInline
  = InlineNever
  | InlineFullyApplied
  | InlinePartiallyApplied {_pragmaInlineArgsNum :: Int}
  deriving stock (Show, Eq, Ord, Data, Generic)

newtype PragmaUnroll = PragmaUnroll
  { _pragmaUnrollDepth :: Int
  }
  deriving stock (Show, Eq, Ord, Data, Generic)

data Pragmas = Pragmas
  { _pragmasInline :: Maybe PragmaInline,
    _pragmasUnroll :: Maybe PragmaUnroll
  }
  deriving stock (Show, Eq, Ord, Data, Generic)

makeLenses ''PragmaUnroll
makeLenses ''Pragmas

instance Hashable PragmaInline

instance Hashable PragmaUnroll

instance Hashable Pragmas

instance FromJSON Pragmas where
  parseJSON = toAesonParser id parsePragmas
    where
      parsePragmas :: Parse YamlError Pragmas
      parsePragmas = do
        _pragmasInline <- keyMay "inline" parseInline
        _pragmasUnroll <- keyMay "unroll" parseUnroll
        return Pragmas {..}

      parseInline :: Parse YamlError PragmaInline
      parseInline = parseInlineArgsNum Aeson.<|> parseInlineBool
        where
          parseInlineArgsNum :: Parse YamlError PragmaInline
          parseInlineArgsNum = do
            _pragmaInlineArgsNum <- asIntegral
            return InlinePartiallyApplied {..}

          parseInlineBool :: Parse YamlError PragmaInline
          parseInlineBool = do
            b <- asBool
            if
                | b -> return InlineFullyApplied
                | otherwise -> return InlineNever

      parseUnroll :: Parse YamlError PragmaUnroll
      parseUnroll = do
        _pragmaUnrollDepth <- asIntegral
        return PragmaUnroll {..}

-- | The Semigroup `<>` is used to propagate pragmas from an enclosing context.
-- For example, if `p1` are the pragmas declared for a module `M`, and `p2` the
-- pragmas declared for a function `f` inside `M`, then the actual pragmas for
-- `f` are `p1 <> p2`.
instance Semigroup Pragmas where
  p1 <> p2 =
    Pragmas
      { _pragmasInline = p2 ^. pragmasInline <|> p1 ^. pragmasInline,
        _pragmasUnroll = p2 ^. pragmasUnroll <|> p1 ^. pragmasUnroll
      }

instance Monoid Pragmas where
  mempty =
    Pragmas
      { _pragmasInline = Nothing,
        _pragmasUnroll = Nothing
      }
