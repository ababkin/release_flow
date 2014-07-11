{-# LANGUAGE TemplateHaskell #-}

module Integration.Main (fakeWorldIntegrationTestCases) where

import           Test.Tasty                 (TestTree)
import           Test.Tasty.HUnit           (testCase, (@?=))

import           Control.Monad.State.Strict (State, get, put, runState)
import           Control.Monad.Trans.Either (EitherT, runEitherT)
import           Data.List                  (intercalate)

import           Interpreter.State          (World (..), defaultWorld, Input(..), defaultInput, Output(..), initialOutput, interpret)
import           Program.Release            (program)
import           Types                      (Tag (..), Version (..))
import Control.Lens ((%=), (^.), makeLenses)

import Integration.TestCases.Common

makeLenses ''FakeWorldTestCase

makeLenses ''Input
makeLenses ''Output
makeLenses ''World

testCases :: [FakeWorldTestCase]
testCases = [noReleaseInProgress, releaseInProgressGood, releaseInProgressBad]


fakeWorldIntegrationTestCases :: [TestTree]
fakeWorldIntegrationTestCases = map fakeWorldTestCase testCases

fakeWorldTestCase :: FakeWorldTestCase -> TestTree
fakeWorldTestCase tc = testCase (tc^.testDescription) $
  (run (tc^.input)) @?= (tc^.expectedOutput)
  where
    run :: Input -> Output
    run input = output
      where
        output = _wOutput endWorld
          where
            ((), endWorld) = runState stateInterpretation startWorld
              where
                startWorld = defaultWorld {
                  _wInput = input
                }

                stateInterpretation :: State World ()
                stateInterpretation = do
                  eitherResult <- runEitherT $ interpret program
                  logMessages $ either (:[]) id eitherResult

                logMessages :: [String] -> State World ()
                logMessages e = wOutput.oLog %= (\message -> e ++ message)

