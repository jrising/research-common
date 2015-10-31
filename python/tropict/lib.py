def in_newworld(lon, lat):
    """Return True if this point is part of the New World continent."""
    assert lat <= 30 and lat >= -30
    return (lon < -50 and lon > -120) if lat >= 10 else (lon < -30 and lon > -100)
