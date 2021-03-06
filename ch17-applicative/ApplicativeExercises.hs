{-# LANGUAGE FlexibleInstances #-}

module ApplicativeExercises where

import Control.Applicative
import Data.Monoid
import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes

-----------------------------------------------------------------------------------

newtype Identity a = Identity a
                   deriving (Eq, Ord, Show)

instance Functor Identity where
  fmap f (Identity x) = Identity $ f x

instance Applicative Identity where
  pure = Identity
  (Identity f) <*> (Identity a) = Identity $ f a

instance (Arbitrary a) => Arbitrary (Identity a) where
  arbitrary = Identity <$> arbitrary

instance (Eq a) => EqProp (Identity a) where (=-=) = eq

-----------------------------------------------------------------------------------

newtype Constant a b = Constant { getConstant :: a }
                     deriving (Eq, Ord, Show)

instance Functor (Constant a) where
  fmap _ (Constant a) = Constant a

instance Monoid a => Applicative (Constant a) where
  pure a = Constant mempty
  Constant x <*> Constant x' = Constant $ x `mappend` x'

instance (Arbitrary a) => Arbitrary (Constant a b) where
  arbitrary = Constant <$> arbitrary

instance (Eq a) => EqProp (Constant a b) where (=-=) = eq

-----------------------------------------------------------------------------------

data List a = Nil
            | Cons a (List a)
            deriving (Eq, Show)

instance Functor List where
  fmap _ Nil = Nil
  fmap f (Cons x xs) = Cons (f x) (fmap f xs)

instance Applicative List where
  pure x              = Cons x Nil
  (Cons f fs) <*> xs  = (fmap f xs) `append` (fs <*> xs)
  _           <*> _   = Nil

append :: List a -> List a -> List a
append Nil ys = ys
append (Cons x xs) ys = Cons x $ xs `append` ys

instance Arbitrary a => Arbitrary (List a) where
  arbitrary = do
    a <- arbitrary
    frequency
      [
        (1, return Nil),
        (2, return $ Cons a Nil),
        (4, return $ Cons a (Cons a Nil)),
        (8, return $ Cons a (Cons a (Cons a (Cons a (Cons a Nil)))))
      ]

instance Eq a => EqProp (List a) where (=-=) = eq

-----------------------------------------------------------------------------------

data Two a b = Two a b
             deriving (Eq, Show)

instance Functor (Two a) where
  fmap f (Two a b) = Two a $ f b

instance (Monoid a) => Applicative (Two a) where
  pure x = Two mempty x
  (Two x f) <*> (Two x' y) = Two (x <> x') $ f y

instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
  arbitrary = Two <$> arbitrary <*> arbitrary

instance (Eq a, Eq b) => EqProp (Two a b) where (=-=) = eq

-----------------------------------------------------------------------------------

data Three a b c = Three a b c
                 deriving (Eq, Show)

instance Functor (Three a b) where
  fmap f (Three a b c) = Three a b $ f c

instance (Monoid a, Monoid b) => Applicative (Three a b) where
  pure x = Three mempty mempty x
  (Three x y f) <*> (Three x' y' z) = Three (x <> x') (y <> y') $ f z

instance (Arbitrary a, Arbitrary b, Arbitrary c) => Arbitrary (Three a b c) where
  arbitrary = liftA3 Three arbitrary arbitrary arbitrary

instance (Eq a, Eq b, Eq c) => EqProp (Three a b c) where (=-=) = eq

-----------------------------------------------------------------------------------

data Three' a b = Three' a b b
                deriving (Eq, Show)

instance Functor (Three' a) where
  fmap f (Three' a b b') = Three' a (f b) $ f b'

instance (Monoid a) => Applicative (Three' a) where
  pure x = Three' mempty x x
  (Three' x f f') <*> (Three' x' y y') = Three' (x <> x') (f y) $ f' y'

instance (Arbitrary a, Arbitrary b) => Arbitrary (Three' a b) where
  arbitrary = do
    a  <- arbitrary
    b  <- arbitrary
    return (Three' a b b)

instance (Eq a, Eq b) => EqProp (Three' a b) where (=-=) = eq

-----------------------------------------------------------------------------------

data Four a b c d = Four a b c d
                  deriving (Eq, Show)

instance Functor (Four a b c) where
  fmap f (Four a b c d) = Four a b c $ f d

instance (Monoid a, Monoid b, Monoid c) => Applicative (Four a b c) where
  pure x = Four mempty mempty mempty x
  (Four x y z f) <*> (Four x' y' z' a) = Four (x <> x') (y <> y') (z <> z') $ f a

instance (Arbitrary a, Arbitrary b, Arbitrary c, Arbitrary d) => Arbitrary (Four a b c d) where
  arbitrary = do
    a  <- arbitrary
    b  <- arbitrary
    c  <- arbitrary
    d  <- arbitrary
    return (Four a b c d)

instance (Eq a, Eq b, Eq c, Eq d) => EqProp (Four a b c d) where (=-=) = eq

-----------------------------------------------------------------------------------

data Four' a b = Four' a a a b
               deriving (Eq, Show)

instance Functor (Four' a) where
  fmap f (Four' a a' a'' b) = Four' a a' a'' $ f b

instance (Monoid a) => Applicative (Four' a) where
  pure x = Four' mempty mempty mempty x
  (Four' x y z f) <*> (Four' x' y' z' b) = Four' (x <> x') (y <> y') (z <> z') $ f b

instance (Arbitrary a, Arbitrary b) => Arbitrary (Four' a b) where
  arbitrary = do
    a  <- arbitrary
    b  <- arbitrary
    return (Four' a a a b)

instance (Eq a, Eq b) => EqProp (Four' a b) where (=-=) = eq

-----------------------------------------------------------------------------------

data Four'' a b = Four'' a b b b
               deriving (Eq, Show)

instance Functor (Four'' a) where
  fmap f (Four'' a b' b'' b) = Four'' a (f b') (f b'') $ f b

instance (Monoid a) => Applicative (Four'' a) where
  pure x = Four'' mempty x x x
  (Four'' x f f' f'') <*> (Four'' x' b b' b'') = Four'' (x <> x') (f b) (f' b') $ f'' b''

instance (Arbitrary a, Arbitrary b) => Arbitrary (Four'' a b) where
  arbitrary = do
    a  <- arbitrary
    b  <- arbitrary
    return (Four'' a b b b)

instance (Eq a, Eq b) => EqProp (Four'' a b) where (=-=) = eq

-----------------------------------------------------------------------------------

-- search --> haskell applicative function checkers
-- https://stackoverflow.com/questions/36009335/how-do-i-test-this-applicative-instance-with-checkers-no-instance-for-coarbitr

-- https://begriffs.com/posts/2017-01-14-design-use-quickcheck.html

-- https://hackage.haskell.org/package/checkers
-- https://hackage.haskell.org/package/checkers-0.4.11/docs/Test-QuickCheck-Classes.html

-- https://github.com/conal/checkers
-- https://github.com/conal/checkers/blob/master/src/Test/QuickCheck/Classes.hs

main = do

  putStrLn "\nTesting Applicative : Identity"
  quickBatch $ applicative (undefined :: Identity (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting Applicative : Constant"
  quickBatch $ applicative (undefined :: Constant [String] (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting Applicative : List"
  quickBatch $ applicative (undefined :: List (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Two"
  quickBatch $ applicative (undefined :: Two String (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Three"
  quickBatch $ applicative (undefined :: Three String (Maybe String) (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Three'"
  quickBatch $ applicative (undefined :: Three' String (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Four"
  quickBatch $ applicative (undefined :: Four String (Maybe String) [String] (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Four'"
  quickBatch $ applicative (undefined :: Four' [String] (Int, Double, Char))

-----------------------------------------------------------------------------------

  putStrLn "\nTesting applicative Four''"
  quickBatch $ applicative (undefined :: Four'' [String] (Int, Double, Char))

-----------------------------------------------------------------------------------
