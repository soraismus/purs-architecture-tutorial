module Example.Four where

import Prelude
import Data.Array
import Control.Plus (Plus)

import Halogen
import qualified Halogen.HTML.Indexed as H
import qualified Halogen.HTML.Events.Indexed as E

import qualified Example.CounterRem as Counter
import Example.Two (CounterSlot(..))
import Example.Three (State(..), addCounter, initialState)

data Input a = AddCounter a

listRemUI :: forall g p s. (Functor g)
          => ParentComponentP State _ Input Counter.Input g CounterSlot p
listRemUI = component' render eval peek
    where
        render :: Render State Input CounterSlot
        render state =
            H.div_ [ H.h1_ [ H.text "Counters" ]
                   , H.ul_ (map (H.slot <<< CounterSlot) state.counterArray)
                   , H.button [ E.onClick $ E.input_ AddCounter ]
                              [ H.text "Add Counter" ]
                   ]

        eval :: EvalP Input State _ Input Counter.Input g CounterSlot p
        eval (AddCounter next) = do
            modify addCounter
            pure next

        peek :: Peek State _ Input Counter.Input g CounterSlot p
        peek (ChildF counterSlot queryAction) =
            case queryAction of
                 Counter.Remove _ ->
                    modify $ removeCounter counterSlot
                 _ ->
                    pure unit

removeCounter :: CounterSlot -> State -> State
removeCounter (CounterSlot index) state =
    state { counterArray = filter (/= index) state.counterArray }

-- ui :: forall g p. (Plus g)
--    => InstalledComponent State Unit Input Counter.Input g CounterSlot p
-- ui = install' listRemUI mkCounter
--     where
--         mkCounter (CounterSlot _) =
--             createChild Counter.ui (installedState unit)