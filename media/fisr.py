import struct
import math


# From:
# http://stackoverflow.com/a/14431225/39182
def float2bits(f):
    s = struct.pack('>f', f)
    return struct.unpack('>l', s)[0]


def bits2float(b):
    s = struct.pack('>l', b)
    return struct.unpack('>f', s)[0]


# Transcribed from the original C:
# https://en.wikipedia.org/wiki/Fast_inverse_square_root
def Q_rsqrt(number):
    threehalfs = 1.5

    x2 = number * 0.5
    y = number
    i = float2bits(y)  # evil floating point bit level hacking
    i = 0x5f3759df - (i >> 1)  # what the fuck?
    y = bits2float(i)
    y = y * (threehalfs - (x2 * y * y))  # 1st iteration
    # y = y * (threehalfs - (x2 * y * y))  # 2nd iteration, this can be removed

    return y


def rsqrt(number):
    return 1 / math.sqrt(number)


def compare(number):
    return abs(rsqrt(number) - Q_rsqrt(number))


if __name__ == '__main__':
    print(500, compare(500.0))
    print(0.001, compare(0.001))
