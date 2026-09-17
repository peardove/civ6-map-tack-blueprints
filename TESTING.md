# UI regression checks

## v0.1.2 live validation

Validated in Civilization VI 1.0.12.68, DX12, Simplified Chinese, with Detailed Map Tacks enabled, on the official Huge TSL Earth map.

- The blueprint button is inserted into the native MapPinStack immediately before AddPinButton. It stays correctly positioned when the list grows from zero to 24 pins.
- Clicking the injected button opens the centered blueprint panel.
- Importing the eight-city preset from an empty list reports 24 created, zero failed. Pins appear in the list and on the map, including unexplored plots; Detailed Map Tacks displays yield indicators.
- Repeating the import reports zero created and 24 updated.
- The removal button opens a native in-game confirmation dialog. Choosing No returns to the blueprint panel without removing pins.

The running session was patched through the game's enabled debugging interface for these checks. A fresh load from the installed files is a separate regression check; do not infer it from a successful hot-load.

## v0.1.3 capital correction

The live game reported Canberra at `(115, 13)`: plains, river, fresh water, coastal land, appeal 6. The capital triangle is therefore city `(115, 13)`, harbor `(115, 12)`, and commercial hub `(114, 13)`. The commercial-hub plot is riverside and adjacent to both the city center and harbor. This replaces the original coastal-only city plot at `(116, 14)`.

## Manual release checklist

1. Install using install.ps1, then load a game with the mod enabled.
2. Open the pin list: verify one blueprint button above Add Pin, with no overlap.
3. Open and close the panel by button and Escape; reopen it.
4. Select each preset and confirm the summary changes (18/24/30 pins).
5. Import twice and verify the second import updates rather than duplicates.
6. Place a manual pin on a target plot and verify it is skipped, not overwritten.
7. In a disposable test save, switch from ten to six cities and verify surplus blueprint pins disappear while manual pins remain.
8. Check both No and Yes in the removal confirmation on a disposable save.
9. Open on a mismatched map: verify import is disabled.
10. Repeat without Detailed Map Tacks and on other UI scales.

## Implementation notes

InGame.lua loads AddUserInterfaces with isHidden=true. A visible injected child in another context does not imply the source context is visible. QueuePopup/DequeuePopup must manage the panel's root context.

The stock map pin list is inside an unnamed LuaContext. Traverse the bounded child tree to find MapPinStack; an absolute lookup through a guessed context name fails. Insert into the stack and preserve the original child order instead of using a position overlay.

Use PopupDialogInGame for shared confirmation UI. PopupDialog:new requires local popup controls and instances not provided by this mod.
