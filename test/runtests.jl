using SmallInts
using Base.Test

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

            @test U(x) << U(y) === rem(x << y, U)
            @test U(x) >> U(y) === U(x >> y)
            @test U(x) >>> U(y) === U(x >>> y)

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
