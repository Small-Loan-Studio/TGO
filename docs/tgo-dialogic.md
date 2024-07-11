# Dialogic2

- [Dialogic2](#dialogic2)
  - [Questions](#questions)
      - [1. we need an opinion for how to structure dialogue -- Dialogic2 (henceforth DL2) uses a thing called timelines to represent the flow of a conversation. do we write one timeline per conversation, one per character, one per character/per act](#1-we-need-an-opinion-for-how-to-structure-dialogue----dialogic2-henceforth-dl2-uses-a-thing-called-timelines-to-represent-the-flow-of-a-conversation-do-we-write-one-timeline-per-conversation-one-per-character-one-per-characterper-act)


The following are the results of an initial survey into Dialogic 2.

## Demo code
We have a test project that does some basic experimentation with Dialogic 2 here:
https://github.com/Small-Loan-Studio/dl2-demo

## Q&A

### 1. How to structure dialogue
> We need an opinion for how to structure dialogue -- Dialogic2 uses a thing
> called timelines to represent the flow of a conversation. do we write one
> timeline per conversation, one per character, one per character/per act

We should use one timeline per conversation.

**Follow ups**:  
How does that work in a situation where we have one NPC that has different
“phases” of dialogue during a quest? Presumably we don't want to have to
track which timeline to launch from non-dialogue code?

### 2. Triggering conversations
> How do we trigger conversations from code?

- To launch a new conversation: `Dialogic.start(’conversation’)`
- To check for active conversations: `if Dialogic.current_timeline != null:`

### 3. Interacting with state
> How do we specify the variables / functions available to be used in conversation?
> Is there any kind of syntax checking (e.g. if we have a signal to emit/function
> to call/variable to check during a conversation how many times will a typo fuck
> us over)

Dialogic has a variable system in place. `Set Variable` allows us to change this from
within Dialogic timelines. [`Signal`][signal-link] allows us to exfiltrate state from within the
conversation

`Dialogic.VAR.<variable_name>` also allows outside code to access timeline state.
Documentation [here][dot-var-link]

There doesn't seem to be autocompletion or syntax checking. We could be missing it, but
will make variable, function, signal typos will be difficult to catch automatically.

[signal-link]: https://docs.dialogic.pro/dialogic-signals.html#1-signal-event
[dot-var-link]: https://docs.dialogic.pro/variables.html

### 4. How to test
> When making changes to a timeline what's the best way to test those changes?
> Can we construct a custom scene that makes it easy to set variables that are
> needed to get to a specific point in time
>
> Do we have to start at the top or can we kick that test scene / conversation
> off wherever we want

Specific timelines can be tested with Play Timeline, which runs the current
timeline. No obvious out-of-the-box ways to identify necessary variables to
set but doing it manually in shouldn't be too bad. It can be done in the
timeline directly or edited in the variables tab.

> if the narrative team is the one testing can we make it simple for our
> non-technical folks

It's likely we'll want to build some test infrastructure for narrative here.

### 5. Custom UI
> How does UI customization work for Dialogic? Can we do speech bubbles?

#### TODO

### 6. Input: Masking Input
> Does Dialogic keep our character from walking around randomly when in conversation?

There does not seem to be any input masking with the default UI.
    
### 7. Input: Choices 
> Do we get keyboard/controller and mouse interaction by default?
#### TODO

### 8. Translation
> Is there a translation story / how is that handled?
#### TODO

### 9. Engine-External Dialogue?
> can we export conversations and make it so that we can edit them then load at
> runtime? The goal would be to enable narrative team to make changes without
> rebuilding the whole game

#### TODO