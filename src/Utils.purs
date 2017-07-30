module Utils
    ( mapM
    , mapMapM
    , mapStrMapM
    , foldError
    , lookupOrDefault
    , removeElement
    ) where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (find, foldl)
import Data.List (List(..), (:))
import Data.List as L
import Data.Map (Map)
import Data.Map as M
import Data.Maybe (Maybe, maybe)
import Data.Set (Set)
import Data.Set as S
import Data.StrMap (StrMap)
import Data.StrMap as SM
import Data.Traversable (class Foldable, traverse)
import Data.Tuple (Tuple(..))

foldError :: forall a f e. Foldable f => f (Either e a) -> Either e (List a)
foldError items =
    foldl folder (Right L.Nil) items
    where
        folder b a =
            case b of
            Left err -> Left err
            Right xb ->
                case a of
                Left err -> Left err
                Right xa -> Right $ xa : xb

mapM :: forall m a b. Applicative m => (a -> m b) -> List a -> m (List b)
mapM = traverse

mapMapM :: forall m k v w. Monad m => Ord k  => (k -> v -> m w) -> Map k v -> m (Map k w)
mapMapM f m = do
    l <- mapM mapper (M.toUnfoldable m)
    pure $ M.fromFoldable l
    where
        mapper (Tuple a b) = do
            c <- f a b
            pure $ Tuple a c

mapStrMapM :: forall m v w. Monad m => (String -> v -> m w) -> StrMap v -> m (StrMap w)
mapStrMapM f m = do
    l <- mapM mapper (SM.toUnfoldable m)
    pure $ SM.fromFoldable l
    where
        mapper (Tuple a b) = do
            c <- f a b
            pure $ Tuple a c

lookupOrDefault :: forall k v. Ord k => v -> k -> Map k v -> v
lookupOrDefault default key m = maybe default id $ M.lookup key m

removeElement :: forall a. Ord a => (a -> Boolean) -> Set a -> { element :: Maybe a, rest :: Set a }
removeElement p s = { element, rest: maybe s (\x -> S.delete x s) element }
    where element = find p s 