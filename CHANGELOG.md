# Changelog — Nexus Platform

## Session 2: UI Refinement & Server Resilience (May 25, 2026)

### Server: SSE Streaming Resilience
- **`server/src/router.ts`** — Hardened SSE ReadableStream to prevent `ERR_INCOMPLETE_CHUNKED_ENCODING`:
  - Added `safeClose()` helper that gracefully handles already-closed/errored streams
  - Wrapped post-stream operations (`analyticsService.recordMessage`, `memoryService.store`) in individual try/catch so failures don't prevent stream close
  - Added `cancel()` handler to the ReadableStream to mark `closed = true` on client disconnect, stopping further writes
  - Added explicit `Transfer-Encoding: chunked` header

### Client: Streaming Resilience
- **`client/src/hooks/useStream.js`** — Graceful stream read failure handling:
  - Wrapped `reader.read()` in try/catch — on `ERR_INCOMPLETE_CHUNKED_ENCODING`, breaks gracefully instead of throwing (partial content preserved)
  - Flushes remaining buffered data after stream ends (discards partial JSON)
  - Supressed noisy SyntaxError logging for incomplete chunk boundaries

### Streaming Cursor
- **`client/src/components/shared/MessageBubble.jsx`** — Replaced old bouncing dots with a refined blinking vertical-line cursor:
  - Glowing `cursor-blink` animation (cyan/indigo glow based on persona color)
  - Shown only on the last streaming message with content
  - Smooth opacity transition between visible and dim states

### BrokerView UI Redesign
- **`client/src/components/BrokerView.jsx`** — Major middle-section improvement:
  - **Iteration progress bar**: Shows "Step X of Y — description" with animated percentage bar at the top of the chat area during streaming
  - **Processing overview banner**: Real-time tool-activity panel showing running/completed tools
  - **User message labels**: Added "You" labels above user messages with avatar icon
  - **Enhanced streaming indicator**: Animated pulsing dot + spinning loader for "Analyzing Markets" state
  - **Richer empty state**: Icon container, feature hints (Real-time data, Market news, Trend analysis)
  - Smoother message transitions with staggered fade-in animations

### TutorView Loading State
- **`client/src/components/TutorView.jsx`** — Replaced custom inline bounce-dot animation with shared `TypingIndicator` component:
  - Dynamic label: "Crafting questions...", "Preparing exercises...", or "Building curriculum..." based on input mode
  - Retained activity tool chips for ongoing tool call visibility
  - Consistent visual language with other agent views

### Agent Loop Optimizations (Previous Session)
- **`server/src/core/agent-loop.ts`**:
  - Smart early termination: detects complete answers to exit loop early
  - Tool result caching (`ToolCache` class) — same tool + args within same request returns cached result
  - `iteration_start` / `iteration_end` event streaming for real-time progress
  - Consecutive failures counter (persists across retries, not reset per iteration)
  - Parallel tool execution with `Promise.all`

### Shared Components (Previous Session)
- **`client/src/components/shared/MessageBubble.jsx`** — Unified chat bubble with markdown, code highlighting, tool cards
- **`client/src/components/shared/TypingIndicator.jsx`** — Animated bouncing dots with Framer Motion
- **`client/src/components/shared/LoadingSkeleton.jsx`** — Staggered skeleton loaders
- **`client/src/hooks/useStream.js`** — RAF-batched SSE streaming, persistent chat history, iteration tracking

### Views Refactored to Shared Components (Previous Sessions)
- ChatView, LegalView, SupportView, BrokerView, MovieView, TutorView → use `MessageBubble`
- ResearchView, VoyageView, MedView → use `TypingIndicator` + `LoadingSkeleton`
- `AgentActivityPanel` → iteration progress bar with spring animations
