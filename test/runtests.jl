using SmallInts
using Base.Test

for (n,I) in enumerate((Int1, Int2, Int4))
    nbits = 1 << (n-1)
    minval = (Int8(-1) << (nbits-1))
    maxval = (Int8(1) << (nbits-1)) - Int8(1)
    for x in minval:maxval
        @test Int8(I(x)) === x
        @test I(x).val === x
        @test rem(x, I) === I(x)
        @test convert(I, x) === I(x)
        @test typemin(I).val == ~typemax(I).val

        @test rem(I(x), I) === I(x)
        @test rem(I(x), Bool) === rem(x, Bool)
        @test rem(rem(x, Bool), I) === I(rem(x, Bool) ? 1 : 0)
        @test convert(I, I(x)) === I(x)
        @test convert(I, rem(x, Bool)) === rem(rem(x, Bool), I)
        if x == rem(x, Bool)
            @test convert(Bool, I(x)) === rem(I(x), Bool)
        else
            @test_throws InexactError convert(Bool, I(x))
        end

        if x < 0
            @test leading_zeros(I(x)) == 0
            @test leading_ones(I(x)) == leading_zeros(~I(x))
        else
            @test leading_zeros(I(x)) ==
                leading_zeros(x) - leading_zeros(maxval) + 1
            @test leading_ones(I(x)) == 0
        end
        @test trailing_zeros(I(x)) ==
            min(trailing_zeros(x), trailing_ones(maxval) + 1)
        if x == 0
            @test trailing_ones(I(x)) == 0
        elseif x == -1
            @test trailing_ones(I(x)) == nbits
        else
            @test trailing_ones(I(x)) == trailing_ones(x)
        end

        @test ~I(x) === rem(~x, I)
        @test +I(x) === rem(+x, I)
        @test -I(x) === rem(-x, I)
        @test abs(I(x)) === rem(abs(x), I)

        for y in minval:maxval
            @test I(x) & I(y) === I(x & y)
            @test I(x) | I(y) === I(x | y)
            @test I(x) $ I(y) === I(x $ y)

            if y < 0
                @test I(x) << Int(y) === I(0)
                @test I(x) >> Int(y) === I(x < 0 ? -1 : 0)
                @test I(x) >>> Int(y) === I(0)
            else
                @test I(x) << Int(y) === rem(x << y, I)
                @test I(x) >> Int(y) === I(x >> y)
                @test I(x) >>> Int(y) ===
                    rem((x >>> y) & (Int8(-1) >>> (8 - nbits + y)), I)
            end

            @test (I(x) == I(y)) === (x == y)
            @test (I(x) != I(y)) === (x != y)
            @test (I(x) <= I(y)) === (x <= y)
            @test (I(x) < I(y)) === (x < y)
            @test (I(x) >= I(y)) === (x >= y)
            @test (I(x) > I(y)) === (x > y)

            @test I(x) + I(y) === rem(x + y, I)
            @test I(x) - I(y) === rem(x - y, I)
            @test I(x) * I(y) === rem(x * y, I)
            if y == 0 || (x == minval && y == -1)
                @test_throws DivideError div(I(x), I(y))
                @test_throws DivideError fld(I(x), I(y))
                @test_throws DivideError cld(I(x), I(y))
            else
                @test div(I(x), I(y)) === I(div(x, y))
                @test fld(I(x), I(y)) === I(fld(x, y))
                @test cld(I(x), I(y)) === I(cld(x, y))
            end
            if y == 0
                @test_throws DivideError rem(I(x), I(y))
                @test_throws DivideError mod(I(x), I(y))
            else
                @test rem(I(x), I(y)) === I(rem(x, y))
                @test mod(I(x), I(y)) === I(mod(x, y))
            end
        end
    end

    @test_throws InexactError convert(I, -9)
    @test_throws InexactError convert(I, 8)
end

for (n,U) in enumerate((UInt1, UInt2, UInt4))
    nbits = 1 << (n-1)
    maxval = (0x01 << nbits) - 0x01
    for x in 0x00:maxval
        @test UInt8(U(x)) === x
        @test U(x).val === x
        @test rem(x, U) === U(x)
        @test convert(U, x) === U(x)

        @test rem(U(x), U) === U(x)
        @test rem(U(x), Bool) === rem(x, Bool)
        @test rem(rem(x, Bool), U) === U(rem(x, Bool) ? 1 : 0)
        @test convert(U, U(x)) === U(x)
        @test convert(U, rem(x, Bool)) === rem(rem(x, Bool), U)
        if x == rem(x, Bool)
            @test convert(Bool, U(x)) === rem(U(x), Bool)
        else
            @test_throws InexactError convert(Bool, U(x))
        end

        @test leading_zeros(U(x)) ==
            leading_zeros(x) - leading_zeros(maxval)
        @test leading_ones(U(x)) == leading_zeros(~U(x))
        @test trailing_zeros(U(x)) ==
            min(trailing_zeros(x), trailing_ones(maxval))
        @test trailing_ones(U(x)) == trailing_ones(x)

        @test ~U(x) === rem(~x, U)
        @test +U(x) === rem(+x, U)
        @test -U(x) === rem(-x, U)
        @test abs(U(x)) === rem(abs(x), U)

        for y in 0x00:maxval
            @test U(x) & U(y) === U(x & y)
            @test U(x) | U(y) === U(x | y)
            @test U(x) $ U(y) === U(x $ y)

            @test U(x) << Int(y) === rem(x << y, U)
            @test U(x) >> Int(y) === U(x >> y)
            @test U(x) >>> Int(y) === U(x >>> y)

            @test (U(x) == U(y)) === (x == y)
            @test (U(x) != U(y)) === (x != y)
            @test (U(x) <= U(y)) === (x <= y)
            @test (U(x) < U(y)) === (x < y)
            @test (U(x) >= U(y)) === (x >= y)
            @test (U(x) > U(y)) === (x > y)

            @test U(x) + U(y) === rem(x + y, U)
            @test U(x) - U(y) === rem(x - y, U)
            @test U(x) * U(y) === rem(x * y, U)
            if y == 0
                @test_throws DivideError div(U(x), U(y))
                @test_throws DivideError rem(U(x), U(y))
                @test_throws DivideError fld(U(x), U(y))
                @test_throws DivideError mod(U(x), U(y))
                @test_throws DivideError cld(U(x), U(y))
            else
                @test div(U(x), U(y)) === U(div(x, y))
                @test rem(U(x), U(y)) === U(rem(x, y))
                @test fld(U(x), U(y)) === U(fld(x, y))
                @test mod(U(x), U(y)) === U(mod(x, y))
                @test cld(U(x), U(y)) === U(cld(x, y))
            end
        end
    end

    @test_throws InexactError convert(U, -1)
    @test_throws InexactError convert(U, 16)
end
