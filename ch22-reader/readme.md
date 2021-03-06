### Definition
 - Reader is a way of stringing functions together when all those functions are awaiting one input
   from a shared environment. The important intuition is that it’s another way of abstracting out
   function application and gives us a way to do computation in terms of an argument that hasn’t been
   supplied yet. We use this most often when we have a constant value that we will obtain from somewhere
   outside our program that will be an argument to a whole bunch of functions. Using `Reader` allows us
   to avoid passing that argument around explicitly.

***Reader kind***
```haskell
Prelude> :k (->)
(->) :: TYPE q -> TYPE r -> *
```

***Functor Reader***
```haskell
data (->) a b

instance Functor ((->) r) where

  fmap = (.)

newtype Reader r a = Reader { runReader :: r -> a }

instance Functor (Reader r) where
  fmap :: (a -> b) -> Reader r a -> Reader r b
  fmap f (Reader ra) = Reader $ \r -> f (ra r)
  
OR
  fmap :: (a -> b) -> Reader r a -> Reader r b
  fmap f (Reader ra) = Reader $ (f . ra)

-- visualizing the Functor pattern for Reader
-- (<$>) :: (a -> b) ->     f a  ->     f b
-- (<$>) :: (a -> b) -> (r -> a) -> (r -> b)
```

```haskell
-- Sample Functor Reader
Prelude> fmap (+3) (*5) 7
38

Prelude> fmap (runReader $ Reader (+3)) (runReader $ Reader (*5)) 7
38
```

***Function Composition***
```haskell
compose :: (b -> c) -> (a -> b) -> (a -> c)
compose f g = \x -> f (g x)

-- e.g.
-- \r -> f (ra r) -- Functor Reader
-- \x -> f (g  x) -- function composition
```

***Applicative Reader***
```haskell
instance Applicative (Reader r) where
  pure :: a -> Reader r a
  pure a = Reader $ \_ -> a
  
  (<*>) :: Reader r (a -> b) -> Reader r a -> Reader r b
  (Reader rab) <*> (Reader ra) = Reader $ \x -> rab x (ra x)

-- visualizing the Applicative pattern for Reader
-- pure :: a ->     f a
-- pure :: a -> (r -> a)

-- (<*>) ::    f (a -> b) ->     f a  ->     f b
-- (<*>) :: (r -> a -> b) -> (r -> a) -> (r -> b)
```

```haskell
-- Sample Applicative Reader
Prelude> (+) <$> (+3) <*> (*5) $ 7
45

Prelude> (+) <$> (runReader $ Reader (+3)) <*> (runReader $ Reader (*5)) $ 7
45
```

***Monad Reader***
```haskell
instance Monad (Reader r) where
  return = pure

  (>>=) :: Reader r a -> (a -> Reader r b) -> Reader r b
  (Reader ra) >>= aRb = Reader $ \x -> runReader (aRb (ra x)) x

-- visualizing the Monad pattern for Reader
-- return = pure
-- OR
-- return :: a ->     m a
-- return :: a -> (r -> a)

-- (>>=) ::     m a  -> (a -> (   m b)) ->     m b
-- (>>=) :: (r -> a) -> (a -> (r -> b)) -> (r -> b)
```

```haskell
-- Sample Monad Reader
Prelude> (+3) >>= return . (*5) $ 7
50

Prelude> (runReader $ Reader (+3)) >>= return . (runReader $ Reader (*5)) $ 7
50
```

 - When we use >>= to feed a monadic value to a function, the result is always a monadic value.
   So, in this case, when we feed a function to another function, the result is a function as well.
   That’s why the result starts off as a lambda.
 
 - All of the implementations of >>= so far somehow isolated the result from the monadic value and
   then applied the function `aRb` to that result. The same thing happens here. To get the result
   from a function, we need to apply it to something, which is why we use `(ra x)` here, and then
   we apply `aRb` to that. `aRb` returns a monadic value, which is a function in our case, so we apply
   it to `x` as well


***Monad Transformer***
 - A monad transformer is a special type that takes a monad as an argument and returns a monad as a result.
   It allows us to combine two monads into one that shares the behaviors of both, such as allowing us to
   add exception handling to a `State` monad. It is somewhat common to create a stack of transformers
   to create one large monad that has features from several monads, for example, rolling `Reader`,
   `Either`, and `IO` together to get a monad that captures the behavior of waiting for an argument that
   will get passed around to multiple functions but is likely to come in via some kind of `I/O` action
   and has the possibility of failure we might like to catch. Often this stack will be given a type
   alias for convenience.

### For further reading
 - [All About Monads](https://wiki.haskell.org/All_About_Monads)
 - [All About Monads - The Reader monad](https://wiki.haskell.org/All_About_Monads#The_Reader_monad)
 - [Real World Haskell - by Bryan O'Sullivan](http://book.realworldhaskell.org/read/)
 - [Real World Haskell - Programming with Monads](http://book.realworldhaskell.org/read/programming-with-monads.html)
 - [Simple Reader Monad](https://blog.ssanj.net/posts/2014-09-23-A-Simple-Reader-Monad-Example.html)
 - [The Reader Monad Part 1 - by Jonathan Fischoff](https://hackernoon.com/the-reader-monad-part-1-1e4d947983a8)
 - [The Reader Monad Part 2 - by Jonathan Fischoff](https://medium.com/@jonathangfischoff/monad-reader-part-2-d812dda1d03e)
 - [Reader and Writer Monads](https://mmhaskell.com/monads-4/)
 - [What I Wish I Knew When Learning Haskell - by Stephen Diehl](http://dev.stephendiehl.com/hask/#monads)
