# elouisDissertation
Code supporting my dissertation

I plan to break the folder structure down by chapter.

Chapter 3 deals with model fidelity evaluation and comparison and pulls from two main examples: a comparison of two beam theory models and a comparison of two dynamic system settling time models. Both models are implemented in MATLAB. There is also a military ground vehicle model comparison with two MATLAB and one pyCHRONO model. I will add these at some point - need permission from owners of the models

Chapter 4 involves uncertainty quantification. Most of this section of the repository is lifted from the existing SREC GitHub. There are a handful of files lifted from MathWorks and the SFU Optimization Test Case Library.

Chapter 5 introduces PIPR, which generates a set of choice solutions to a MOO problem, given a rank-order of objectives and a subset of critical sub-problems. This chapter also utilizes some files from MathWorks and the SFU library

Chapter 6 combines the methods introduced in Chapters 4 and 5 to approach a mutli-objective ground vehicle design problem with aleatory uncertainty.

Several of the processes introduced here also lend themselves well to animation, or in some cases are even best visualized using an animation. To support some of the figures and explanations in the document, I've made a good handful of gifs, mainly for the design space exploration process and the PIPR loop
