module SmallInts

export Int1, Int2, Int4
export UInt1, UInt2, UInt4

immutable Int1 <: Signed; val::Int8; end
immutable Int2 <: Signed; val::Int8; end
immutable Int4 <: Signed; val::Int8; end
immutable UInt1 <: Unsigned; val::UInt8; end
immutable UInt2 <: Unsigned; val::UInt8; end
immutable UInt4 <: Unsigned; val::UInt8; end

nbits(::Type{Int1}) = 1
nbits(::Type{Int2}) = 2
nbits(::Type{Int4}) = 4
nbits(::Type{UInt1}) = 1
nbits(::Type{UInt2}) = 2
nbits(::Type{UInt4}) = 4

import Base: print, show
import Base: typemin, typemax, rem, convert, promote_rule
import Base: leading_zeros, leading_ones, trailing_zeros, trailing_ones
import Base: ~, &, |, $
import Base: <<, >>, >>>
import Base: <, <=
import Base: +, -, abs, *, div, rem, fld, mod, cld

typealias BaseSigned Union{Int8, Int16, Int32, Int64, Int128}
typealias BaseUnsigned Union{UInt8, UInt16, UInt32, UInt64, UInt128}
typealias BaseInteger Union{BaseSigned, BaseUnsigned}

for I in (:Int1, :Int2, :Int4)
    @eval begin
        print(io::IO, x::$I) = print(io, x.val)
        show(io::IO, x::$I) = show(io, x.val)

        sext(x::$I) = $I(x.val << (8 - nbits($I)) >> (8 - nbits($I)))

        typemin(::Type{$I}) = $I(Int8(-1) << (nbits($I)-1))
        typemax(::Type{$I}) = $I(Int8(1) << (nbits($I)-1) - Int8(1))
        rem(x::$I, ::Type{$I}) = x
        rem(x::$I, ::Type{Bool}) = rem(x.val, Bool)
        rem{T<:BaseInteger}(x::$I, ::Type{T}) = rem(x.val, T)
        # rem{T<:Integer}(x::$I, ::Type{T}) = rem(x.val, T)
        rem(x::Bool, ::Type{$I}) = $I(rem(x, Int8))
        rem{T<:BaseInteger}(x::T, ::Type{$I}) = sext($I(rem(x, Int8)))
        # rem{T<:Integer}(x::T, ::Type{$I}) = sext($I(rem(x, Int8)))
        convert(::Type{$I}, x::$I) = x
        convert(::Type{$I}, x::Bool) = $I(convert(Int8, x))
        function convert{T<:BaseInteger}(::Type{$I}, x::T)
            (x<typemin($I).val) | (x>typemax($I).val) && throw(InexactError())
            rem(x, $I)
        end
        # function convert{T<:Integer}(::Type{$I}, x::T)
        #     (x<typemin($I).val) | (x>typemax($I).val) && throw(InexactError())
        #     rem(x, $I)
        # end
        convert(::Type{Bool}, x::$I) = convert(Bool, x.val)
        convert{T<:BaseInteger}(::Type{T}, x::$I) = convert(T, x.val)
        # convert{T<:Integer}(::Type{T}, x::$I) = convert(T, x.val)
        promote_rule{T<:BaseSigned}(::Type{$I}, ::Type{T}) = T

        leading_zeros(x::$I) =
            leading_zeros(x.val << (8 - nbits($I)) | Int8(-1) >>> nbits($I))
        leading_ones(x::$I) = leading_ones(x.val << (8 - nbits($I)))
        trailing_zeros(x::$I) = trailing_zeros(x.val | Int8(-1) << nbits($I))
        trailing_ones(x::$I) =
            trailing_ones(x.val & ~(Int8(-1) << nbits($I)))

        ~(x::$I) = $I(~x.val)
        (&)(x::$I, y::$I) = $I(x.val & y.val)
        (|)(x::$I, y::$I) = $I(x.val | y.val)
        ($)(x::$I, y::$I) = $I(x.val $ y.val)

        <<(x::$I, y::Int) = rem(x.val << y, $I)
        >>(x::$I, y::Int) = $I(x.val >> y)
        >>>(x::$I, y::Int) = rem((x.val & ~(Int(-1) << nbits($I))) >>> y, $I)

        <=(x::$I, y::$I) = x.val <= y.val
        <(x::$I, y::$I) = x.val < y.val

        +(x::$I) = x
        -(x::$I) = rem(-x.val, $I)
        abs(x::$I) = rem(abs(x.val), $I)
        +(x::$I, y::$I) = rem(x.val + y.val, $I)
        -(x::$I, y::$I) = rem(x.val - y.val, $I)
        *(x::$I, y::$I) = rem(x.val * y.val, $I)
        function div(x::$I, y::$I)
            (x == typemin($I)) & (y == $I(-1)) && throw(DivideError())
            rem(div(x.val, y.val), $I)
        end
        rem(x::$I, y::$I) = rem(rem(x.val, y.val), $I)
        function fld(x::$I, y::$I)
            (x == typemin($I)) & (y == $I(-1)) && throw(DivideError())
            rem(fld(x.val, y.val), $I)
        end
        mod(x::$I, y::$I) = rem(mod(x.val, y.val), $I)
        function cld(x::$I, y::$I)
            (x == typemin($I)) & (y == $I(-1)) && throw(DivideError())
            rem(cld(x.val, y.val), $I)
        end
    end
end

for U in (:UInt1, :UInt2, :UInt4)
    @eval begin
        print(io::IO, x::$U) = print(io, x.val)
        show(io::IO, x::$U) = show(io, x.val)

        mask(::Type{$U}) = (0x01 << nbits($U)) - 0x01
        # zext(x::$U) = x << (8 - nbits($IU) >> (8 - nbits($U))

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
