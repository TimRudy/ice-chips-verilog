## The Validation Contract

Test benches are great for giving confidence in the code. However, this note explains the site infrastructure for providing structured code, running the tests on it, and doing so repeatably, to give a guarantee of everything published on the site.

A main question is how the .ice component that you download and use in Icestudio is tested (with a guarantee), when it is the .v file source code published here that is explicitly run through a test. The .ice file is tested indirectly, it seems. So is there a role for human error in all this? Read on for the answer.

<details>
<summary>Outline</summary>
<br />

&ensp;&ensp;[Problem Statement](#problem-statement)

&ensp;&ensp;[Requirements](#requirements) · problem goes away if 3 requirements are met

&ensp;&ensp;[Solution](#solution) · an Automation script

&ensp;&ensp;[Verilog Structure](#verilog-structure) · examining the .v and .ice code &rarr; statement of no essential differences between the two

&ensp;&ensp;[Proof is in the Outputting](#proof-is-in-the-outputting)

&ensp;&ensp;&ensp;&ensp;[File content and structure](#file-content-and-structure) · how the two files are the same and the abstractions they are based on

&ensp;&ensp;&ensp;&ensp;[Code-generation script](#code-generation-script) · what the Automation script does exactly

&ensp;&ensp;[The Contract](#the-contract)

&ensp;&ensp;&ensp;&ensp;[Preamble](#preamble) · Automation is actually one unit of work, with two artifacts (files) as output

&ensp;&ensp;&ensp;&ensp;[Statement](#statement) · Validation applies equally to all published file versions

&ensp;&ensp;&ensp;&ensp;[Coda](#coda) · list of 4 assumptions and questions, with affirmative answers

&ensp;&ensp;[Appendices](#appendices)

&ensp;&ensp;&ensp;&ensp;[Notes and details about generated code structure](#notes-and-details-about-generated-code-structure)

&ensp;&ensp;&ensp;&ensp;[What is a good test bench?](#what-is-a-good-test-bench) · goal, policy & guidelines

</details>

### Problem Statement

Validation means running the code here on the GitHub site through the program "iverilog" to test it; this happens once, if and when Verilog code ever changes (or is introduced in a new device in the project).

The validation step runs the Device Under Test (DUT), the 74xx.v file, with its test bench the 74xx-tb.v file.

The .ice file (component within the Icestudio collection) is seen on the right-hand side in this example comparison. Note its working code is shared in common with the .v file - which if there's one thing I'd like you to take away from this today, is the thing to remember. And note other parts of the code are not in common - which is a problem statement.

**7485.v file (left) compared to the Verilog code in 7485_Comparator.ice (right):**

<img src="/images/7485_compare.png" title="Compare Verilog content" width="100%">
<br />

I can guarantee you the .ice component is signed off, verified and validated.

How?

### Requirements

Well, from the .ice file point of view, validation relies on three specifics:

1. It relies on the fact that between the .v file and the .ice file, the Verilog working code is an identical copy.

    This you can see for yourself if you open and compare each .v and .ice file pair.

2. It relies on a formal or contractual type of guarantee that this code is truly common, for all time (not subject to human error, for example).

    This second criterion is deeply important since we are talking about validation. It addresses some questions:

    - Are you looking at a good copy-pasting job if you open and compare the files to check them?

    - Worse - Could the code in a file be tweaked? Could code that **was at one time** identical be, temporarily, not identical awaiting the next proper release?! ..."There was a slight issue and we are working on it."

    No. There won't be errors and shoddy handling. It's not going to happen.

3. It relies on the same type of guarantee that no error can be introduced in the extra, non-shared code (i.e. header and footer), which is a mapping layer between the .v and .ice file pair.

    Same comment: No. There won't be any errors.

### Solution

A site-level or "infrastructure" guarantee takes care of the two files sharing their code, and this is the Automation feature of IceChips. There is a code-generation script "`generate`" that:

- Generates a Verilog code template per device; then

- Copies/merges the Verilog code inserted there by human developer, from .v file to .ice file.

That is the source of both files; thus all three requirements are met by the script. Further automation, which is to validate those files by running the Verilog, then publish them to the repo, is discussed [below](#coda The Contract -> Coda).

The diff of the 7485 files represents a typical pair of files. The next section goes through details and explanation, with reference to Verilog. If you don't have time, skip ahead. In the following section, Proof, we'll come back to code-generation and tie it to the Validation Contract for this project.

### Verilog Structure

Here is a run-down of the relationship of the two sides; how the Verilog you see comprises four sections; and how the high-level structure of four sections is always the same, in fact, for any IceChips device.

<details>
<summary>Side-by-side</summary>
<br />

You may want context for the two pieces of code, so here's a quick recap:

- **The left-hand side** is a **module**. That's the basic unit of packaging up Verilog, and the basic unit of hierarchy in a Verilog design or circuit schematic (also referred to as a component or device). A module can be composed of nested modules; a module can have parameters (see top line) that allow for reuse of the same code in a different use case, such as instantiating it with a different number of bits.

    The module is a testable unit of functionality:

    - It has its I/O interface; it has its functionality, completely documented. The interface, which is the "ports", is a strict boundary of access around the internals - like an API in software. The functionality has two traits: it's defined entirely in terms of the I/Os; and it's limited in scope, mainly because there shouldn't be too many I/Os - these make it just like a function in software, actually.

    - It's testable for practical reasons too - because it plugs into a test bench. Instantiate it, and wire up:

        > ttl_7485 #(.WIDTH_IN(WIDTH_IN), ...) dut(.A(A), .B(B), ...);

        This is a "ttl_7485" module (the type). It's instantiated as "dut" (the name). And its I/Os "A", "B", and the rest are listed, connecting to sources/sinks in the test bench. Incidentally the instantiation line here counts as nesting a module inside another, because the test bench file is a module.

- **The right-hand side** you will see by double-clicking the .ice component in Icestudio to open its code.

    This is Verilog without the module wrapper; all redundancy is removed for user convenience; but Icestudio wraps this code in a module internally.

    On the right-hand side, a central concern is to group related pins of the component into vectors (see the assign lines). "A" and "B" are vectors; but the other variables are single pins/single bits.

</details>
<br />

<details>
<summary>Top-to-bottom</summary>
<br />

I was thinking the identical section would stand out the most in the code diff. It's supposed to; but the non-identical sections seem to catch the eye. Anyway, the important thing that's not apparent from only looking at one example... is that the high-level structure of the Verilog in IceChips is **always the same** and it's of this form:

- First, the declaration of the interface (I/O list) - Parameters are included as a prerequisite;

- Second, the required variables (these are inside the identical section) - These comprise all the computed results; other ones may be present to track intermediates;

- Third, the actual "procedural" Verilog code, the portion that implements the functionality and is written by the developer - Horizontal dividers in the .v file delineate where this code was inserted by human intervention;

- Fourth, assignments - These connect the inside (Verilog program code) to the outside by wiring to the ports of the interface.

(As a side note, if one enumerates sub-sections also, to take a more fine-grained view of the above, then the structure of the Verilog is still always the same for every IceChips device. Consistent ordering schemes ensure this. There are 3 sub-sections within the first section; being parameters, inputs, then outputs. There are 2 sub-sections within the second section, being output results variables and other, intermediate variables. There are 2 sub-sections within the fourth section, being always the inputs followed by the outputs. That is 8 total.)

</details>
<br />

<details>
<summary>The essential differences</summary>
<br />

The segments of code, side-by-side, are all "structurally identical". This becomes apparent, and satisfyingly so, if one knows the prescribed purpose of each line.

Refer again to the diff.

5 wires on the right-hand side (RHS) put in an appearance - but they replicate the 5 inputs on the LHS. Each of these 5 declaration lines then gets a corresponding assign statement at the bottom; 10 lines of extra code on RHS; these recreate the "input" line semantics of the LHS. It is structurally identical, bringing in the same amount of data, but the noticeable difference in detail on the RHS is incorporating named individual pins that are part of the .ice component.

For the 3 outputs on the LHS, replication like the above is not needed. The assign statements for the 3 outputs match up on both sides; it is just that there are named pins on the RHS, in place of the "output" line variables on the LHS.

</details>
<br />

The take-away from the top-to-bottom view?

All the highlighted lines - the first and fourth segments, that is - are just plumbing code. They're declarative. This code constitutes variable and wire declarations, then wire connections. All of it deals specifically with the I/Os of the device; but the I/O list is pre-determined; so the take-away is this code is all amenable to auto-generation.

The take-away from the essential differences?

There are no essential differences. (I give more details [later on this page](#notes-and-details-about-generated-code-structure) that explain the "DELAY" parameters if you are curious.)

### Proof is in the Outputting

The concluding point is that Automation, which is code-generation, creates these files.

A template or skeleton is created. I/O definitions make up a header, and wiring makes up a footer, as seen in the example 7485. Logic code forms the guts of the file.

#### File content and structure:

- The .v and .ice files are intimately related by the fact they perform the same functionality, contain the same code, and are tied together by their I/O specs (I/O textual details differ);

- The non-identical segments are declarative code only, constituting wrappers;

- The wrappers are basically wiring; for example, the collation of individual Input and Output pins into vectors: "assign A = {pin15_A3, pin13_A2, pin12_A1, pin10_A0}". On the RHS, vectors are constructed: the abstract from the concrete. On the LHS, vectors are implicit: they're part of the abstraction;

- Abstractions are used in the logic code; they're what makes the code identical.

#### Code-generation script:

- Starts with metadata which gives the "form-factor" of a device; that is, the names and ordering of its input and output ports;

- Provides the rolling up of pins such as "{... pin12_A1, pin10_A0}" to a vector "A";

- Generates skeleton .v and .ice files;

- Clones the common code block, written by human developer, from .v file to .ice file, thus completing the files.

I've not yet published the "generate" script. You'll be hearing more about it, to be mentioned on the Wiki.

Think of the simulated Integrated Circuit like an Integrated Circuit: The header and footer of the file, the code-generated part, is like the DIP package with the complement of metal pins - it provides a given form-factor. The logic code put in the file is like the silicon chip, fresh from the fab line, that's dropped in and bonded inside.

### The Contract

#### Preamble:

The responsibility to physically handle and publish the files is built into IceChips Automation.

- The Automation process creates the .v and the .ice files, inserts a common code block, and finally publishes them (with accompanying certification by running the tests);

- The creation of those files is, in fact, one logical unit of work - there happen to be two artifacts coming out.

That's the basis for the contract: The Automation controls the essential commonality and the differences between .ice file and counterpart .v file, and thus lends repeatability and a closed-ended nature to the process of validation.

#### Statement:

- Every device published in the library is validated by test bench, and the validation applies equally to both .v and .ice versions of the device.

This completes the "steps in the proof" that your .ice device has been validated.

#### Coda:

There are some implicit aspects, some real-world assumptions, that require comment:

1. **Validation step is performed.** Yes, the Verilog is run using ["iverilog"][link-iverilogu], getting a Pass or Fail from each test bench. This is a separate part of Automation. It's tied in with publishing to GitHub (CI/CD GitHub Actions). Observe there is a [![Build/Test Status][ico-workflow-status]][link-workflow] badge below the main title of the README; this links to the validation run results.

    For those interested in the technicals about this, look in the [scripts folder](/scripts/validate "scripts and validate folders"), and see [package.json](/scripts/package.json "package.json") which includes the entry point "npm test". For GitHub Action on any commit change to the project, see [workflows folder .yml file](/.github/workflows/ci-validate.yml "CI/CD configuration: ci-validate.yml").

2. **There is a test bench.** The extremely skeptical and the subversives need to know: the validation step when publishing to GitHub requires a test bench paired with each device file, by automated check, not just by policy; so there will never be a device published without its test bench being completed.

3. **The test bench could be bogus?** Refer to myself or the community for community review of test benches, because they are all published. I provide [my perspective on tests below](#what-is-a-good-test-bench).

4. **Automation script exists.** The IceChips "generate" script needs to be published with the library for community review, as a pillar of the claims leading to the Validation Contract. True. We are working on this. (There was just a little issue: The code is ugly and needs to be cleaned up.)

[Top](#top)

## <!-- -->

### Appendices

#### Notes and details about generated code structure

For the "DELAY" parameters seen in the example, just a quick note that these are declared on the left-hand side only, and they are present in the output assignments, because the primary purpose of the LHS, the module, is to run simulations and tests. The parameters affect the time domain, the response time of a simulated circuit element, so they're useful and can be very important to model a real-world, clocked synchronous circuit.

On the other hand, the primary purpose of the RHS is synthesis of a hardware circuit: logic gates and components. Since it targets these real circuit components, synthesis provides no artificial parametrization for delays.

#### What is a good test bench?

An "engineering" or pragmatic technologist's point of view is used in managing this library. I take a stab at policy and guidelines for the tests, below.

Verification of device behaviour is not going to be mathematical (Formal Verification). It is more in the spirit of what a commercial or legal contract provides: stating the detailed description of the device, its functions and transformations, and stating that it conforms to the same, as a sign-off of quality from the provider.

The test bench, actually, states and makes explicit all those details of functions and transformations. It stands as a contract. (If there is a gap discovered later, it can be adjudicated in the court of open source and remedied with a pull request.)

##### Self-checking:

On a technical note: IceChips testing is a binary, Pass/Fail exercise, because tests are written with a set of macros. These macros are "assert" statements that log a failure message if the stated condition is not met. Take a look at tests in any test bench, for example [7485-tb.v](/source-7400/7485-tb.v "7485 test bench"), and see [tbhelper.v](/includes/tbhelper.v "Assert macros").

Pass/Fail tests or tests that self-check the outputs mean the test bench is not just doing a demonstration run of the device, with a waveform result that needs to be interpreted.

##### Policy:

The sequence of tests is intended to be comprehensive. It's intended to cover **the entire scope** of behaviour - which means running through all basic inputs (and examining all outputs); running through all mixtures and crosses of allowed inputs or a realistic sampling thereof (if not **all**, then certainly all that represent "interestingly" different mixtures); and a realistic sampling of the complete ranges of data values; a coverage of all corner-cases that are reasonably deduced from all inputs, outputs, complete ranges of data values, and the stated functionality; and all this with an awareness and an intentionality applied to the semantics of the data, and semantics of the operations the device applies.

##### Guidelines:

Two guidelines, from opposite poles:

1. **Good Cop.** In practice, life does not usually give the chance to prove everything with 100% coverage.
    - Get the most value out of limited coverage that "explores the parameter space";
    - Focus on if each test is adding value by thinking about the [80%/20% rule][link-pareto];
    - Do not try to reach an ideal of 100% of all test values; reach for an ideal in logical case coverage;
    - Certainly do not spend run-time looping through 100% of all possibilities if you do not demonstrate what is resulting inside the loops.

2. **Bad Cop.** Applied technology and testing are usually [not good enough][link-swbugs]. Use the advantages of Open Source - time, resources, extra thought?
    - If there's any doubt, apply more diligence;
    - The aim and goal of your work **must** be a defect-free product;
    - Cover the domain;
    - And really: Review later, to check if you covered the domain. The domain here on this hardware (compared to most software) is not that huge.

Working on a test suite late at night and it is boring...? Try to think of the long term, the big picture:

<div style="font-family: monospace">
&ensp;&ensp;Functionality that is unassailable, works right the first time, and doesn't break at a later time? Priceless.
</div>

If Intel had put a test suite in place under this policy and guidelines, they would have caught their [Pentium floating-point divide bug][link-hwbug] of 1993. Covering a nice range, running some number theory calculations, particularly using prime numbers, and checking the exact results in tables, would have forestalled cranking out $475 million in silicon paper weights.

[ico-workflow-status]: https://github.com/TimRudy/ice-chips-verilog/actions/workflows/ci-validate.yml/badge.svg
[link-workflow]: https://github.com/TimRudy/ice-chips-verilog/actions/workflows/ci-validate.yml "See the latest test report"
[link-iverilogu]: https://steveicarus.github.io/iverilog/usage/index.html
[link-pareto]: https://en.wikipedia.org/wiki/Pareto_principle
[link-swbugs]: https://www.techrepublic.com/article/microsoft-fixes-windows-and-internet-explorer-zero-day-flaws-in-latest-patch-tuesday
[link-hwbug]: https://en.wikipedia.org/wiki/Pentium_FDIV_bug
