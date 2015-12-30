module SmallInts

export UInt1, UInt2, UInt4

immutable UInt1 <: Unsigned
    val::UInt8
end
immutable UInt2 <: Unsigned
    val::UInt8
end
immutable UInt4 <: Unsigned
    val::UInt8
end

nbits(::Type{UInt1}) = 1
nbits(::Type{UInt2}) = 2
nbits(::Type{UInt4}) = 4

import Base: typemin, typemax, rem, convert, promote_rule
import Base: leading_zeros, leading_ones, trailing_zeros, trailing_ones
import Base: ~, &, |, $
import Base: <<, >>, >>>
import Base: <, <=
import Base: +, -, abs, *, div, rem, fld, mod, cld

typealias BaseSigned Union{Int8, Int16, Int32, Int64, Int128}
typealias BaseUnsigned Union{UInt8, UInt16, UInt32, UInt64, UInt128}
typealias BaseInteger Union{BaseSigned, BaseUnsigned}

for U in (:UInt1, :UInt2, :UInt4)
    @eval begin
        mask(::Type{$U}) = (0x01 << nbits($U)) - 0x01

        typemin(::Type{$U}) = $U(0x00)
        typemax(::Type{$U}) = $U(mask($U))
        rem(x::$U, ::Type{$U}) = x
        rem(x::$U, ::Type{Bool}) = rem(x.val, Bool)
        rem{T<:BaseInteger}(x::$U, ::Type{T}) = rem(x.val, T)
        rem(x::Bool, ::Type{$U}) = $U(rem(x, UInt8))
        rem{T<:BaseInteger}(x::T, ::Type{$U}) = $U(rem(x, UInt8) & mask($U))
        convert(::Type{$U}, x::$U) = x
        convert(::Type{$U}, x::Bool) = $U(convert(UInt8, x))
        function convert{T<:BaseInteger}(::Type{$U}, x::T)
            (x<typemin($U).val) | (x>typemax($U).val) && throw(InexactError())
            rem(x, $U)
        end
        convert(::Type{Bool}, x::$U) = convert(Bool, x.val)
        convert{T<:BaseInteger}(::Type{T}, x::$U) = convert(T, x.val)
        promote_rule{T<:BaseUnsigned}(::Type{$U}, ::Type{T}) = T

        leading_zeros(x::$U) = leading_zeros(x.val) - (8 - nbits($U))
        leading_ones(x::$U) = leading_ones(x.val | ~mask($U)) - (8 - nbits($U))
        trailing_zeros(x::$U) = trailing_zeros(x.val | ~mask($U))
        trailing_ones(x::$U) = trailing_ones(x.val)
        ~(x::$U) = rem(~x.val, $U)
        (&)(x::$U, y::$U) = $U(x.val & y.val)
        (|)(x::$U, y::$U) = $U(x.val | y.val)
        ($)(x::$U, y::$U) = $U(x.val $ y.val)

        <<(x::$U, y::Int) = rem(x.val << y, $U)
        >>(x::$U, y::Int) = $U(x.val >> y)
        >>>(x::$U, y::Int) = >>(x, y)

        <=(x::$U, y::$U) = x.val <= y.val
        <(x::$U, y::$U) = x.val < y.val

        +(x::$U) = x
        -(x::$U) = rem(-x.val, $U)
        abs(x::$U) = x
        +(x::$U, y::$U) = rem(x.val + y.val, $U)
        -(x::$U, y::$U) = rem(x.val - y.val, $U)
        *(x::$U, y::$U) = rem(x.val * y.val, $U)
        div(x::$U, y::$U) = rem(div(x.val, y.val), $U)
        rem(x::$U, y::$U) = rem(rem(x.val, y.val), $U)
        fld(x::$U, y::$U) = rem(fld(x.val, y.val), $U)
        mod(x::$U, y::$U) = rem(mod(x.val, y.val), $U)
        cld(x::$U, y::$U) = rem(cld(x.val, y.val), $U)
    end
end

end
