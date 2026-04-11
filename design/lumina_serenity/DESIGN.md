# Design System Strategy: Emotional Luminescence

## 1. Overview & Creative North Star
The North Star for this design system is **"The Digital Sanctuary."** 

We are moving away from the clinical, "dashboard" feel of typical health apps. Instead, we are creating an editorial, high-end experience that feels like a reflective journal. The design breaks the standard mobile template by using **intentional asymmetry** (e.g., off-center headers or oversized mood indicators) and **layered depth**. By emphasizing breathing room and organic shapes, we ensure the user feels "held" rather than "managed."

## 2. Colors & Tonal Architecture
The palette is rooted in deep obsidian tones to reduce cognitive load and eye strain, using vibrant emotional accents to guide the journey.

### The "No-Line" Rule
**Explicit Instruction:** Use of 1px solid borders for sectioning is strictly prohibited. Boundaries must be defined solely through background color shifts. For example, a card should be distinguished from the background by placing a `surface-container-high` element on a `surface` background.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of smoked glass. 
- **Base Layer:** `surface` (#131313) for the main canvas.
- **Secondary Containers:** `surface-container-low` (#1C1B1B) for secondary content.
- **High-Interaction Containers:** `surface-container-highest` (#353534) for primary cards or active mood entries.
By nesting these tiers, we create a natural sense of "importance" without cluttering the screen with lines.

### Glass & Gradient Rule
To achieve a premium "editorial" feel, floating elements (like the navigation bar or top-level mood summaries) must utilize Glassmorphism.
- **Effect:** Use `surface` at 70% opacity with a `20px` backdrop blur.
- **Signature Textures:** Apply a subtle linear gradient from `primary` (#47F3BB) to `primary-container` (#06D6A0) for main CTAs. This creates a "glow" effect rather than a flat, plastic button.

## 3. Typography
We utilize a pairing of **Manrope** for expressive headlines and **Inter** for functional body text. This contrast between "architectural" headers and "utilitarian" body text creates an authoritative yet supportive voice.

*   **Display-LG (Manrope, 3.5rem):** Used for the current day's mood score. It should be oversized and slightly offset to create a signature "high-fashion" layout.
*   **Headline-MD (Manrope, 1.75rem):** For emotional prompts (e.g., "How are you feeling, Alex?").
*   **Body-LG (Inter, 1rem):** Used for journal entries and descriptions. Increased line height (1.6) is required for readability.
*   **Label-MD (Inter, 0.75rem, All Caps, Tracking +5%):** Used for metadata, such as time stamps or mood categories.

## 4. Elevation & Depth
Hierarchy is achieved through **Tonal Layering** rather than traditional structural dividers.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section to create a soft, natural "recess" effect. 
*   **Ambient Shadows:** For floating elements, use a `32px` blur with 6% opacity. The shadow color must be tinted with the `surface-tint` (#27E0A9) to mimic a soft glow rather than a muddy grey shadow.
*   **The Ghost Border Fallback:** If a boundary is required for accessibility, use the `outline-variant` token at **15% opacity**. Never use 100% opaque borders.

## 5. Components

### Mood Scale (Signature Component)
Instead of a horizontal slider, use a **vertically scrolling "Emotional Column."**
- **Mood Gradients:** Use the designated spectrum (Red to Dark Green) as a subtle background glow behind the emojis.
- **Active State:** The selected emoji should scale by 1.2x and trigger a soft glow using the `primary-fixed` token.

### Buttons (Tactile Sophistication)
- **Primary:** Gradient fill (`primary` to `primary-container`), `xl` (3rem) corner radius, and `headline-sm` typography. 
- **Tertiary:** No background, `on-surface` text with an `xl` rounded corner and a `ghost border` visible only on hover/press.

### Cards & Lists
- **Rule:** Forbid divider lines. Separate list items using `16px` of vertical white space or by alternating between `surface-container-low` and `surface-container`.
- **Anatomy:** Every card must use `lg` (2rem) rounded corners to maintain the "supportive and calm" tone.

### Contextual Components
- **Mood Pulse (New):** A large, semi-transparent circle behind the daily emoji that slowly "pulses" in size, using the color of the current mood gradient.
- **Glass Bottom Bar:** A floating navigation bar with a `32px` blur, anchored `16px` from the bottom edges to feel detached and modern.

## 6. Do’s and Don’ts

### Do
- **DO** use white space as a structural element. If a screen feels crowded, increase the padding rather than adding a box.
- **DO** use the `secondary` (#FFB784) accent sparingly for "Aha!" moments or reminders to breathe.
- **DO** ensure the large touch targets (minimum 48dp) are maintained even for text-only buttons.

### Don't
- **DON'T** use pure white (#FFFFFF). Always use `on-surface` (#E5E2E1) for text to prevent "vibration" against the dark background.
- **DON'T** use standard system animations. Use "Spring" physics (dampened) for all transitions to evoke a sense of organic movement.
- **DON'T** ever use a 100% opaque #000000 shadow. It destroys the "Digital Sanctuary" atmosphere.