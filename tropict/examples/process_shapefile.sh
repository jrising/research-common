#!/bin/bash

cd "$(dirname "$0")"
python ../make_shapefile.py ../ne_50m_admin_0_countries/ne_50m_admin_0_countries countries

python ../slave_shapefile.py countries.tsr ../ne_50m_admin_0_countries/ne_50m_admin_0_countries countries2

