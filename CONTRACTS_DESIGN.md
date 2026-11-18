# Contracts — replaces the map

Status: implemented. Logic and flow tested headless; screens not yet checked by eye on desktop or phone.

## Why

The map is hard to read, and its rows don't form paths, so there is nothing to plan.
It only does four jobs: set fight difficulty, offer rest/events, give a relic after an elite, lead to the boss.
Contracts replace it with quests tied to the run you're actually building.

## Run flow

Shop → fight → discovery → repeat. 13 turns, turn 13 is the boss.

- Regular fight difficulty follows a fixed curve by turn (replaces node difficulty 1.0 / 1.35 / 1.75).
- Map screen, `ROW_TEMPLATES`, `NODE_INFO` grid, and `user://map.json` are removed.
- Relic and rest panels in `map_screen.gd` stay and are reused as reward screens.
- Events are cut entirely: `EVENTS`, the event panel, and `event_completed` are removed.

## Contract rules (decided)

| Rule | Decision |
|---|---|
| Active at once | Up to 2 |
| When offered | A board of 3 offers appears after discovery whenever a slot is free. Pick 1 or skip. Run starts with a board. |
| Skipped board | Next board rolls 3 fresh offers from your current state. |
| Deadline | Each contract has a turn deadline. Missing it = contract lost, no other penalty. |
| Bounty / side-boss loss | Normal HP damage, same as a regular loss. |
| Run length | 13 turns, unchanged. |

## Contract kinds

**Build** — shape your board.
- Win a fight with N units of faction X (board max is 7).
- Upgrade a Human weapon to Lv.N.
- Make a triple (or: a triple of faction X).
- Reach shop tier N.

**Feat** — play a certain way.
- Win N fights in a row.
- Win with ≤4 units on board.
- Start a fight holding ≥N gold.
- Win without losing a unit.

**Bounty** — an optional extra fight.
- Side fight against a themed board (e.g. "Reaper raiding party").
- Side boss (turn 6+): tougher, best rewards.
- An extra fight does not use up a turn.
- Timing: the bounty fight happens right after your next regular fight (after its discovery pick, before the shop). Your board carries straight in.

## Run-relevance

Offers are generated from current state, not a fixed list:
- Your top 1–2 factions on board → faction-count goals, scaled from what you have now (have 3 → target 5–6).
- Owning a Human with a weapon → weapon-level goal above its current level.
- Only factions active this run (6 of 10) are used.
- One offer per board pushes a faction you aren't playing, with a bigger reward.
- Deadlines are clipped so every offer can finish before turn 13.

## Rewards

Relic · gold · HP · free unit of a faction · permanent stat boost on one unit · rerolls.
Rest (heal / fortify) becomes a reward rather than a map node.

### Reward table (draft numbers, to tune in playtest)

Tier is set by how hard the goal is relative to your current state.

| Tier | Example goal | Skipped board | Next board rolls 3 fresh offers from your current state. |
| Deadline | Reward (pick one shown on card) |
|---|---|---|---|
| Small | Win 2 in a row · reach tier N+1 | 2–3 turns | +8 gold · +10 HP · +1 reroll |
| Medium | +2–3 units of a faction you play · weapon +2 levels · make a triple | 3–4 turns | +15 gold · fortify a unit (+2 ATK / +4 HP) · free unit of that faction |
| Large | Pivot faction goal · 6 of one faction · weapon Lv.7+ | 4–5 turns | Relic (choose 1 of 3) |
| Bounty | Win the side fight | fought after next regular fight | +12 gold or fortify |
| Side boss (turn 6+) | Win the side-boss fight | fought after next regular fight | Relic (choose 1 of 3) + 10 gold |

The relic pool is the existing 8 in `MapScreen.RELICS`. Elites are gone, so Large contracts and side bosses are the only relic sources. Expect 2–3 relics per run.

## UI

- **Contract Board:** one screen, 3 large cards (goal, deadline, reward). Stacks vertically on phones.
- **Tracker:** small strip on the battle screen per active contract, e.g. `Myconids 4/6 · 2 turns left`.
- **Completion:** pop-up, then the reward screen.

## Code shape

- New `contract_system.gd`: offer generator, progress checks, save/load (replaces map save in slots).
- Progress hooks: combat end (`_on_combat_ended`), weapon upgrade, triple merge, tier up, gold at fight start.
- New Contract Board panel (replaces the map panel in `map_screen.gd`, or a new `contract_screen.gd`).
- Remove `_go_to_map_btn`, `_advance_map_row`, `_map_current_row`, `_load_map` / `_save_map`; turn count uses `_round`.
- Save migration: old saves with `map_row` map to the turn number; drop `map_data`.

## Open questions

All original questions are settled:
1. Bounty timing — after the next regular fight.
2. Reward table — drafted above; numbers tuned in playtest. Relics: 2–3 per run, confirmed.
3. Skipped offers — fresh roll.
4. Weapon cap — none for the player; Lv.5–8 goals are reachable.
5. Events — cut.

## Difficulty curve (draft)

Replaces the map's per-node multiplier (combat 1.0, hard 1.35, elite 1.75, boss 2.2).

| Turn | 1–3 | 4–5 | 6–7 | 8–9 | 10–11 | 12 | 13 boss |
|---|---|---|---|---|---|---|---|
| Multiplier | 1.0 | 1.1 | 1.2 | 1.3 | 1.4 | 1.5 | 2.2 |

Bounty side fights: current turn's multiplier +0.15. Side boss: +0.35.
The old map mixed in hard fights (1.35) from turn 3 and elites (1.75) from turn 6, so this curve is gentler mid-run. Bounties put that pressure back for players who choose it.

## Implementation plan

Turn index `_turn` is 0-based: turns 0–11 are regular fights, turn 12 is the boss. Saved under the existing `map_row` key so old saves keep their place.

1. **`scripts/contract_system.gd`** (`class_name ContractSystem`, static data + functions)
   - `RELICS` moves here from `MapScreen`.
   - `difficulty_for_turn(turn)` → curve above.
   - `generate_offers(snapshot)` → 3 contract dicts from run state (board faction counts, active factions, best weapon level, tier, gold, turn, active contracts). Never offers a bounty while one is active; side bosses only from turn 6; deadlines clipped to turn 11.
   - `describe(contract)` / `progress_text(contract, snapshot)` for UI.
   - Goals: `faction_win`, `weapon_level`, `triple`, `tier`, `win_streak`, `small_win`, `gold_hold`, `bounty`, `side_boss`. (Flawless win dropped: summoned tokens dying would make it unfair.)
2. **`scripts/contract_screen.gd`** (`class_name ContractScreen`): overlay with the Contract Board panel (3 cards + Skip) and the relic-pick panel. Uses `Platform.adapt_overlay` like the old map.
3. **`combat_arena.gd`**
   - Remove map vars/functions, rest/event handlers, elite flag, Go-to-Map button.
   - Add `_turn`, `_contracts` (active), `_reward_queue`, `_bonus_rerolls`; save in resources + slot.
   - Flow after discovery: ready bounty → bounty fight; else reward queue → board (if a slot is free and turn < 11) → **Next Fight** button.
   - Next Fight: `_turn += 1`, set difficulty from curve (boss on 12), populate enemy, unlock board.
   - Bounty fight: no turn used, no income, no discovery. Win → reward. Loss → normal HP damage. Then reward queue → board → Next Fight.
   - Progress hooks: combat end, fight start (gold), weapon buy/upgrade/surge, triple, tier up. Deadlines checked when a turn advances.
   - Tracker label under the resource bar: `Turn 4/13 · Myconids 4/6 (2 turns) · Bounty after next fight`.
   - Rewards: gold, HP, reroll (next discovery), fortify (pick a board unit, +2/+4 permanent), free unit (faction-filtered discovery), relic (pick 1 of 3).
4. **Delete** `map_screen.gd` (+ `.uid`), `user://map.json` handling, events.
5. **Verify**: headless Godot parse/run, then play a run through board → bounty → boss.
