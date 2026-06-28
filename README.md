## Elior Hadad
* 213563349
* Eliorhad@post.bgu.ac.il

## Dvir Margalit
* 325119659
* dvirmarg@post.bgu.ac.il

## goal
implementation of log{a}(b) algorithm in .asm
### input:
program base number epsilon
### output:
log_{a}(b) = res

## status:
* (done) parser ; extern sscanf used
* (done) implement log algorithm
* (done) figure out the callback of log ; keep answer in st0
* (done) make a, b integers ; %Lf --> %.0Lf
* (done) debug inacurate answer ; fdivp --> fdivrp
* (done) make long with 16 characters after the dec-point ; %Lf --> %.18Lf format
* (done) format 3.0000000000000000 --> 3 ; %.18Lf --> %.18Lg format
* PASSED THE PDF TESTS --> Done
* check for epsilon < 1e-19 --> usage: (too small, without validation dumping core) (not implemented, not required)

### finished!!!