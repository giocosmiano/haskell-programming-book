module LearnParsers where

import Text.Parser.Combinators
import qualified Data.ByteString.Char8 as C

--
-- A modern parser combinator library with convenient diagnostics
-- https://github.com/ekmett/trifecta/
--
-- Prelude> stack install trifecta
-- https://hackage.haskell.org/package/trifecta-1.5.2
import Text.Trifecta

-----------------------------------------------------------------------------------
-- newtype Reader r a = Reader { runReader :: r -> a }
-- newtype State s a = State { runState :: s -> (a, s) }
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- type Parser a = String -> Maybe (a, String)
-----------------------------------------------------------------------------------
-- `Parser` is a bit like State, plus failure.
-- 1. Await a string value
-- 2. Produce a result which may or may not succeed. A Nothing value means the parse failed.
-- 3. Return a tuple of the value you wanted and whatever’s left of the string that you
--    didn’t consume to produce the value of type `𝑎`.
--
-- The idea here with the `Parser` type is that the State is handling
-- the fact that you need to await an eventual text input and
-- that having parsed something out of that text input results in
-- a new state of the input stream. It also lets you return a value
-- independent of the state, while Maybe handles the possibility
-- of the parser failure.
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- unexpected :: Parsing m => String -> m a
-----------------------------------------------------------------------------------
-- `unexpected` is a means of throwing errors in parsers like trifecta
-- which are an instance of the Parsing typeclass

stop :: Parser a
stop = unexpected "stop"

-- read a single character '1'
one :: Parser Char
one = char '1'

-- read a single character '1', then die
one' :: Parser a
one' = one >> stop
-- equivalent to char '1' >> stop

-- read two characters, '1', and '2'
oneTwo :: Parser Char
oneTwo = char '1' >> char '2'

-- read two characters,
-- '1' and '2', then die
oneTwo' :: Parser a
oneTwo' = oneTwo >> stop

pNL :: [Char] -> IO ()
pNL s = putStrLn ('\n' : s)

-----------------------------------------------------------------------------------
-- char   :: CharParsing m => Char   -> m Char
-- string :: CharParsing m => String -> m String
--
-- parseString :: Parser a
--             -> Text.Trifecta.Delta.Delta
--             -> String
--             -> Result a
--
-- parseByteString :: Parser a
--                 -> Text.Trifecta.Delta.Delta
--                 -> Data.ByteString.Internal.ByteString
--                 -> Result a
-----------------------------------------------------------------------------------
-- The `𝑝` argument in `testParse` function is a parser. Specifically, it’s a character
-- parser. The functions `one` and `oneTwo` have the type Parser Char.

testParse :: Parser Char -> IO ()
testParse p = print $ parseString p mempty "123"

-- e.g.
-- parseString (char 'a') mempty "a"              -> Success 'a'
-- parseString (char 'b' >> char 'c') mempty "bc" -> Success 'c'
-- parseString (string "abc") mempty "abc"        -> Success "abc"
-- parseString (string "abc") mempty "abcdef"     -> Success "abc"
-- parseString integer mempty "123abc"            -> Success 123

-- make sure to `import qualified Data.ByteString.Char8 as C`
-- parseByteString (char 'a') mempty (C.pack "a")              -> Success 'a'
-- parseByteString (char 'b' >> char 'c') mempty (C.pack "bc") -> Success 'c'
-- parseByteString (string "abc") mempty (C.pack "abc")        -> Success "abc"
-- parseByteString (string "abc") mempty (C.pack "abcdef")     -> Success "abc"

-- parseString (char 'b') mempty "a"
-- Failure (interactive):1:1: error: expected: "b"; a<EOF>

-- parseString (char 'b' >> char 'c') mempty "b" ->
-- Failure (interactive):1:2: error: unexpected EOF, expected: "c"

-- parseString (string "abc") mempty "bc" ->
-- Failure (interactive):1:1: error: expected: "abc"; bc<EOF>

-- parseString (string "abc") mempty "ab" ->
-- Failure (interactive):1:1: error: expected: "abc"; ab<EOF>

-- parseString (integer >> eof) mempty "123abc"   -> Success 123
-- Failure (interactive):1:1: error: expected: digit; 123abc<EOF>

-----------------------------------------------------------------------------------

testParseString :: Parser String -> IO ()
testParseString p = print $ parseString p mempty "123"

parsePractice1 :: Parser String
parsePractice1 = string "123"

-----------------------------------------------------------------------------------
-- token parsing
-----------------------------------------------------------------------------------

-- NOT token parsing
-- e.g.
-- parseString (some digit) mempty "123 456"        -> Success "123"
-- parseString (some (some digit)) mempty "123 456" -> Success ["123"]
-- parseString (some integer) mempty "123\n\n 456"  -> Success [123,456]

-- token parsing
-- e.g.
-- parseString pInteger mempty "1\n2\n 3\n"        -> Success [1,2,3]
-- parseString pInteger mempty "123\n 456\n 789\n" -> Success [123,456,789]
pInteger :: Parser [Integer]
pInteger = some $ do
  i <- token (some digit)
  return (read i)

{-

Prelude> s = "1\n2\n3"
Prelude> parseString p' mempty s
Success [1,2,3]
Prelude> parseString (token (some digit)) mempty s
Success "1"
Prelude> parseString (some (token (some digit))) mempty s
Success ["1","2","3"]

Prelude> tknWhole = token $ char 'a' >> char 'b'
Prelude> parseString tknWhole mempty "a b"
Failure (interactive):1:2: error: expected: "b"; a b<EOF>

Prelude> parseString tknWhole mempty "ab ab"
Success 'b'
Prelude> parseString (some tknWhole) mempty "ab ab"
Success "bb"

Prelude> tknCharA = (token (char 'a')) >> char 'b'
Prelude> parseString tknCharA mempty "a b"
Success 'b'
Prelude> parseString (some tknCharA) mempty "a ba b"
Success "bb"
Prelude> parseString (some tknCharA) mempty "a b a b"
Success "b"

Prelude> tknBoth = token (char 'a') >> token (char 'b')
Prelude> parseString (some tknBoth) mempty "a b a b"
Success "bb"

-}

-----------------------------------------------------------------------------------

main = do
  pNL "stop:"
  testParse stop

  pNL "one:"
  testParse one

  pNL "one':"
  testParse one'

  pNL "oneTwo:"
  testParse oneTwo

  pNL "oneTwo':"
  testParse oneTwo'

  putStrLn $ "\nParsing practices"
  pNL "parsePractice1: parseString (string \"123\") mempty \"123\""
  print $ parseString parsePractice1 mempty "123"

  pNL "parsePractice2: parseString (string \"123\" >> eof) mempty \"123\""
  print $ parseString (parsePractice1 >> eof) mempty "123"


-----------------------------------------------------------------------------------

