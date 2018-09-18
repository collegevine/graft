module Graft.Types where

import Control.Applicative ((<|>))
import Control.Lens (Lens')
import Control.Lens.TH
import qualified Data.Map as M
import Data.Text (Text)

class TemplateData a where
    child :: Text -> a -> Maybe Var

newtype GraftData = GraftData {
    _graftDataTemplates :: M.Map String Template
} deriving Show

type Template = [Part]
type VarMap = M.Map Text Var

data Chunk
    = CLit Text
    | CBind Text
    | CLoopStart Text Text
    | CConditionalStart Text
    | CControlEnd
    | CSubTemplate Text Bool
    deriving (Eq, Show)

data Part
    = Lit Text
    | Bind Text
    | Loop Text Text Template --name bound_as subtemplate
    | Conditional Text Template --variable subtemplate
    | SubTemplate Text Bool
    deriving Show

data Var where
    Val :: Text -> Var
    Object :: TemplateData a => a -> Var
    Array :: TemplateData a => [a] -> Var

data GraftError
    = GraftMissingTemplate String
    | GraftMissingVariable Text
    | GraftVariableMismatch Text
    deriving Show

instance Semigroup GraftData where
    (GraftData ta) <> (GraftData tb) = GraftData $ M.union ta tb

instance Monoid GraftData where
    mempty = GraftData M.empty

instance TemplateData a => TemplateData [a] where
    child _ [] = Nothing
    child k (d:dx) = child k d <|> child k dx

instance TemplateData VarMap where
    child = M.lookup

makeClassy ''GraftData
makeClassyPrisms ''GraftError
