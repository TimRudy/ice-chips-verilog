## The Validation Contract

[top-intro]: #desc
Validation means running the code here on the GitHub site through the program "iverilog" to test it; and that's only done once, if and when the code changes.

The .ice file that you download and use in Icestudio, however, is indirectly tested; its working code is shared in common with the .v file, but some parts of the code are not in common, as you see in the file comparison below.

I can guarantee you the .ice component is signed off, verified and validated.

How? Well, the validation step runs the Device Under Test (DUT), the 74xx.v file, with its test bench the 74xx-tb.v file. So for the .ice component, validation relies on three specifics:

### Requirements

1. It relies on the fact that between the .v file and the .ice file, the Verilog working code is an identical copy.

    This you can see for yourself if you open and compare each .v and .ice file pair.

2. It relies on a formal or contractual type of guarantee that this code is truly common, for all time (not subject to human error, for example).

    This second criterion is deeply important since we are talking about validation. It addresses some questions:

    - Could you be seeing a good old copy-pasting job if you open and compare the files to check them?

    - Worse - Could the code in a file be tweaked? Could code that **was at one time** identical be, temporarily, not identical awaiting the next proper release?! ..."There was a slight issue and we are working on it."

    No. There won't be errors and shoddy handling. It's not going to happen.

3. It relies on the same kind of guarantee that no error can be introduced in the extra, non-shared code, which is a mapping layer between the .v and .ice file pair.

    Same comment as above.

### Solution

A site-level or "infrastructure" guarantee takes care of the two files sharing their code, and this is the Automation feature of IceChips. It generates and concatenates Verilog, including the "write-once" portion supplied by human input, and publishes the files. You'll be hearing more about it.

As to what is happening for a typical pair of files, let's take a look.

### Verilog Structure

Compare the 7485.v file (left) to the Verilog code inside 7485_Comparator.ice (right):

<img src="/images/7485_compare.png" title="Compare Verilog content" width="100%">

Here's the context of these two pieces of code, for a quick recap:

#### Side-by-side

- **The left-hand side** is a **module**. That's the basic unit of packaging up Verilog, and the basic unit of hierarchy in a Verilog design or circuit schematic (also referred to as a component or device). A module can be composed of nested modules; a module can have parameters (see top line) that allow for reuse of the same code in a different use case, such as instantiating it with a different number of bits.

    The module is a testable unit of functionality:

    - It has its I/O interface; it has its functionality, completely documented. The interface, which is the "ports", is a strict boundary of access around the internals - like an API in software. The functionality is two things: it's defined entirely in terms of the I/Os; and it's limited in scope, mainly because there shouldn't be too many I/Os - these make it just like a function in software, actually.

    - It's testable for practical reasons, because it plugs into a test bench. Instantiate it, and wire up:

        > ttl_7485 #(.WIDTH_IN(WIDTH_IN), ...) dut(.A(A), .B(B), ...);

        This is a module "ttl_7485" (the type). It's instantiated as "dut" (the name). And its I/Os "A", "B", and the rest are listed, connecting to sources/sinks in the test bench. Incidentally the instantiation line here counts as nesting the module, as the test bench is a module.

- **The right-hand side** you'll see by double-clicking the .ice component in Icestudio to open its code.

    This is Verilog without the module wrapper; all redundancy is removed for user convenience; but Icestudio wraps this code in a module internally.

    On the right-hand side a central concern is to group related pins of the component into vectors (see the assign lines). "A" and "B" are the vectors; the other variables are single pins/single bits.

#### Top-to-bottom

I was thinking the identical section would stand out the most in this code diff. It's supposed to; but the non-identical sections seem to catch the eye. Anyway, the really important thing is not apparent from looking at only one example... that the high-level structure of the Verilog in IceChips is **always the same** and it's of this form:

- First, the declaration of the interface (I/O list) - Parameters are included as a prerequisite

- Second, the required variables - These comprise all the computed results; other ones may be present to track intermediates

- Third, the actual "procedural" Verilog code, the portion that implements the functionality and is written by the developer - Horizontal dividers in the .v file delineate where this code was inserted by human intervention

- Fourth, assignments - These connect the inside (Verilog program code) to the outside by wiring to the ports of the interface

The take-away?

All the highlighted lines - the first and fourth segments, that is - are just plumbing code. They're declarative: the code constitutes variable and wire declarations, then wire connections. All of this deals specifically with the I/Os; the I/Os are pre-determined elements; so, the bottom line is this code is all amenable to auto-generation.

Skip ahead to next section where the topic of auto-generation is tied back to validation, and trust, and integrity.

#### The essential differences?

There is a satisfying regularity to the lines that are different, and the segments of code are all "structurally identical" if you know the prescribed purpose of each line.

Take a look again at the diff.

5 wires on the right-hand side (RHS) put in an appearance - but they replicate the 5 inputs on the LHS. Each of these 5 declaration lines then gets an assign statement at the bottom; 10 lines of extra code on RHS; these recreate the "input" line semantics of the LHS - structurally identical, bringing in the same amount of data, but with the noticeable incorporation of named individual pins that are part of the .ice component.

For the 3 outputs on the LHS, replication like the above is not needed. The 3 assign statements for outputs match up on both sides, just with named pins on the RHS; they're in place of the "output" line variables on the LHS.

In other words, there are no essential differences. (I give some more details [later on this page](#struct-detail) that explain the "DELAY" parameters if you are curious.)

### Proof is in the Outputting

The concluding point is that Automation, which is code-generation, creates these files.

A template or skeleton is created, with the I/O definitions and wiring making up a header and footer, as you see above in the example. Logic code that forms the guts of the file is added.

#### File content and structure:

- The .v and .ice files are intimately related by the fact they perform the same functionality, contain the same code, and are tied together by their I/O specs (these do differ, and need to be made to match);

- The non-identical segments are declarative code only, constituting wrappers;

- The wrappers are basically wiring; for example, one wiring function is to collate scalar elements into vectors; on the LHS, vectors are part of the abstraction and are implicit - on the RHS vectors are constructed: the abstract from the concrete;

- Abstractions are used in the logic code; they're what makes the code identical.

#### Code-generation script:

- Starts with metadata which gives the "form-factor" of a device; that is, the names and the ordering of its input and output ports;

- Provides the rolling up of pins such as "{... pin12_A1, pin10_A0}" to a vector "A";

- Generates skeleton .v and .ice files;

- Clones the common code block, written by human developer, from .v file to .ice file thus completing the files.

The Automation code is a "generate" script (that I've not yet published).

Think of the simulated Integrated Circuit like an Integrated Circuit: The header and footer of the file, the code-generated part, is like a DIP package with metal pins - it provides a given form-factor. The logic code put in the file is like the silicon chip, fresh from the fab line, that's dropped in and bonded inside.

#### Contract:

The responsibility to physically handle and publish the files is built into IceChips Automation.

- The Automation processes create the .v and the .ice files, insert a common code block, and finally publish them (with accompanying certification, by running tests against the .v file);

- The creation of those files is, in fact, one logical unit of work - there happen to be two artifacts coming out.

It's a basis for the contract:

- Every device published in the library is validated by test bench, and the validation applies equally to both .v and .ice versions of the device.

This completes the "steps in the proof" that your .ice device has been validated.

#### What about?

There are some implicit aspects, some real-world assumptions that require comment:

1. **Validation step is performed.** Yes, the Verilog is run using ["iverilog"][link-iverilogu], to get a Pass or Fail from each test bench. This is a separate part of Automation. It's tied in with publishing to GitHub using Travis CI. Observe there is a [![Build Status][ico-travisci]][link-travisci] badge near the main title of the README, and you can click on it to see Travis CI's results of the validation run.

    For those interested in the technicals about this, look in the [scripts folder](/scripts/validate "scripts and validate folders"), and see [package.json](/scripts/package.json "package.json") which includes the entry point "npm test".

2. **There is a test bench.** The extremely skeptical and the subversives need to know: the validation step when publishing to GitHub requires a test bench paired with each device file, by automated check, not just by policy; so there will never be a device published without its test bench being completed.

3. **The test bench could be bogus?** This gets a bit personal; but you can refer to the community for community review of test benches, because they are all published. I provide [my perspective on tests below](#test-bench-desc).

4. **Automation script exists.** The IceChips "generate" script needs to be published with the library for community review, as a pillar of the claims leading to the validation contract. True. We are working on this. (There was just a little issue: The code is ugly and needs to be cleaned up.)

## <!-- -->

<a name="struct-detail"></a>
### Notes and details about generated code structure

For the "DELAY" parameters seen in the example, just a quick note that these are declared on the left-hand side only, and they are present in the output assignments, because the primary purpose of the LHS, the module, is to run simulations and tests. The parameters affect the time domain, the response time of a simulated circuit element, so they're useful and can be very important to model a real-world circuit. (Think of a clocked, synchronous digital circuit, in which settling time to each stable state must account for switching delay and propagation delay.)

On the other hand, the primary purpose of the RHS is synthesis of a real circuit - logic gates and components. Synthesis, as opposed to simulation, targets a real circuit output and there is no artificial parametrization provided for delays.

<a name="test-bench-desc"></a>
### What is a good test bench?

The policy and guidelines that I take a stab at use an engineering or pragmatic technology point of view to manage this library.

The verification of behaviour of a device is not going to be mathematical (Formal Verification); it is more in the spirit of what a commercial or legal contract provides, stating the detailed description of the device, its functions and transformations, and stating that it conforms to the same, as a sign-off of quality from the provider.

The test bench, actually, states and makes explicit all those details of functions and transformations. It can be the contract. And whatever it provides, it is a signifier of quality too.

By the way, on a technical note... IceChips testing is a binary, Pass/Fail exercise, because tests are written with a set of macros. These are simply "assert" statements that log a failure message if the stated condition is not met. Take a look at tests in any test bench, for example [7485-tb.v](/source-7400/7485-tb.v "7485 test bench"), and see [tbhelper.v](/includes/tbhelper.v "Assert macros"). With Pass/Fail tests, the test bench is not just doing a demonstration run of the device, with a waveform result that needs to be interpreted.

#### Policy:

The sequence of tests is intended to be comprehensive. It's intended to cover **the entire scope** of behaviour - which means running through all basic inputs (and examining all outputs); running through all mixtures and crosses of allowed inputs or a realistic sampling thereof (if not **all**, then certainly all that represent "interestingly" different mixtures); and a realistic sampling of the complete ranges of data values; a coverage of all edge-cases that are reasonably deduced from all inputs, outputs, complete ranges of data values, and the stated functionality; and all this with an awareness and an intentionality applied to the semantics of the data and semantics of the operations that the device applies.

So two points, from opposite poles of this endeavour:

#### Guidelines:

1. **Good Cop.** In practice, life does not usually give the chance to prove everything with 100% coverage. Get the most value out of limited coverage that "explores the parameter space"; think about the [80%/20% rule][link-pareto]; do not be redundant, do not spend unneeded effort to reach an ideal of 100%. Certainly do not spend run-time looping through 100% of all possibilities if you do not demonstrate what is resulting inside the loops.

2. **Bad Cop.** Applied technology and testing are usually [not good enough][link-swbugs]. Use the advantages of Open Source - time, resources, extra thought? If there's any doubt, apply more diligence; aim for a defect-free product; write tests with excellence; cover the domain - and really, review to check if you covered it. Here on this hardware, the domain is thankfully limited, much narrower than in software.

The beauty of test suites (in software or hardware) is that they mean **doing it right**. Functionality that is unassailable, works right the first time, and doesn't break at a later time? Priceless.

If Intel had put a test suite in place under this policy and guidelines, I'm going to suggest they would have caught their [Pentium floating-point divide bug][link-hwbug] of 1993. Running some number theory calculations covering a nice range, particularly using prime numbers, comparing the answers to reference numbers, would have forestalled cranking out $475 million in silicon paper weights.

[ico-travisci]: /images/passed.svg

[link-travisci]: https://travis-ci.org/TimRudy/ice-chips-verilog
[link-iverilogu]: https://iverilog.fandom.com/wiki/User_Guide
[link-pareto]: https://en.wikipedia.org/wiki/Pareto_principle
[link-swbugs]: https://www.techrepublic.com/article/microsoft-fixes-windows-and-internet-explorer-zero-day-flaws-in-latest-patch-tuesday
[link-hwbug]: https://en.wikipedia.org/wiki/Pentium_FDIV_bug
