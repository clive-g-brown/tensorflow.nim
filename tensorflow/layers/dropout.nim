## The Dropout Layer basically turns on and off neurons at random with the given rate. Which means
## that at a dropout rate of 0.4 40% of the neurons are "shutoff".
##
## Example:
##
## .. code:: nim
##
##    var proto: seq[Layer] = @[]
##
##    # a Dropoutlayer with a dropoutrate of 0.4.
##    proto.newDropout(0.4)

import options
import ../ops/ops
import ../core/core
import ./layer
{.hint[XDeclaredButNotUsed]:off.}

type Dropout = ref object of Layer
    rate*: float
    shape*: Out

method `$`(layer: Dropout): string = "Dropout(rate:" & $layer.rate & ")"

method make(layer: Dropout, root: Scope): proc(rt: Scope, input: Out): Out = 
        let rrate = Const[float32](root, layer.rate)

        return proc(rt: Scope, input: Out): Out = 
                    if layer.shape == Out(): 
                        layer.shape = root.Shape(input)

                    let random = rt.RandomUniform(layer.shape, TF_FLOAT, some(0), some(0))
                    let mask = rt.GreaterEqual(random, rrate)
                    let scale = rt.Div(rt.Const(1.0, float32), rt.Subtract(rt.Const(1.0, float32), rrate))

                    return rt.Multiply(rt.Multiply(input, scale), rt.Cast(mask, TF_FLOAT))

proc newDropout*(model: var seq[Layer], rate: float) =
    var dropout = new Dropout

    dropout.rate = rate    

    model.add(dropout)

export Dropout,
       `$`,
       newDropout,
       make
