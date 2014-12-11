### Use a sinusoidal approximation to estimate the number of Growing
### Degree-Days above a given threshold, using daily minimum and
### maximum temperatures.
def above_threshold(mins, maxs, threshold):
    # Determine crossing points
    aboves = mins > threshold
    belows = maxs < threshold

    plus_over_2 = (mins + maxs)/2
    minus_over_2 = (maxs - mins)/2
    two_pi = 2*np.pi
    d0s = np.arcsin((threshold - plus_over_2) / minus_over_2) / two_pi
    d1s = .5 - d0s

    d0s[aboves] = 0
    d1s[aboves] = 1
    d0s[belows] = 0
    d1s[belows] = 0

    # Integral
    F1s = -minus_over_2 * np.cos(2*np.pi*d1s) / two_pi + plus_over_2 * d1s
    F0s = -minus_over_2 * np.cos(2*np.pi*d0s) / two_pi + plus_over_2 * d0s
    return np.sum(F1s - F0s - threshold * (d1s - d0s))

### Get the Growing Degree-Days, as degree-days between gdd_start and
### kdd_start, and Killing Degree-Days, as the degree-days above
### kdd_start.
def get_gddkdd(gdd_start, kdd_start):
    dd_lowup = above_threshold(tasmin, tasmax, gdd_start)
    dd_above = above_threshold(tasmin, tasmax, kdd_start)
    dd_lower = dd_lowup - dd_above

    return (dd_lower, dd_above)

