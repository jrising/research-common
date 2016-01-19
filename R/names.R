canonical2worldbank <- function(country) {
    if (country == "Bahamas")
        return("Bahamas, The")
    if (country == "Bosnia & Herzegovina")
        return("Bosnia and Herzegovina")
    if (country == "Egypt")
        return("Egypt, Arab Rep.")
    if (country == "Iran")
        return("Iran, Islamic Rep.")
    if (country == "Saint Lucia")
        return("St. Lucia")
    if (country == "Venezuela")
        return("Venezuela, RB")
    if (country == "Viet Nam")
        return("Vietnam")
    if (country == "Yemen")
        return("Yemen, Rep.")
    if (country == "Cape Verde")
      return("Cabo Verde")
    if (country == "Congo, R. of")
        return("Congo, Rep.")
    if (country == "Congo (ex-Zaire)")
        return("Congo, Dem. Rep.")
    if (country == "Gambia")
        return("Gambia, The")
    if (country == "Hong Kong")
      return("Hong Kong SAR, China")
    if (country == "Marshall Isl.")
      return("Marshall Islands")
    if (country == "Micronesia")
        return("Micronesia, Fed. Sts.")
    if (country %in% c("Saint Kitts & Nevis", "Saint Kitts and Nevis"))
        return("St. Kitts and Nevis")
    if (country %in% c("Saint Vincent & the Grenadines", "St Vincent"))
        return("St. Vincent and the Grenadines")
    if (country %in% c("Sao Tome & Principe", "Sao Tome Prn"))
        return("Sao Tome and Principe")
    if (country == "Solomon Isl.")
      return("Solomon Islands")
    if (country == "Syria")
        return("Syrian Arab Republic")
    if (country %in% c("Timor Leste", "East Timor"))
        return("Timor-Leste")
    if (country == "Trinidad & Tobago")
        return("Trinidad and Tobago")
    if (country == "Antigua & Barbuda")
        return("Antigua and Barbuda")

    if (country %in% c("Andaman &amp; Nicobar Isl. (India)", "Andaman & Nicobar Isl. (India)", "Andaman and Nicobar"))
      return("India")
    if (country %in% c("Australia (Christmas Isl.)", "Australia (Cocos (Keeling) Isl.)", "Australia (Heard &amp; McDonald Isl.)",
                       "Australia (Lord Howe Isl.)", "Australia (Macquarie Isl.)", "Christmas Isl. (Australia)",
                       "Australia (Cocos (Keeling) Isl.)", "Heard & McDonald Isl. (Australia)",
                       "Lord Howe Isl. (Australia)", "Macquarie Isl. (Australia)", "Norfolk Isl. (Australia)", "Cocos Islands", "Christmas Island"))
        return("Australia")
    if (country %in% c("Trindade & Martin Vaz Isl. (Brazil)"))
        return("Brazil")
    if (country %in% c("Chile (Easter Isl.)", "Chile (J. Fernandez, Felix and Ambrosio Isl.)", "Desventuradas Isl. (Chile)",
                       "Easter Isl. (Chile)", "J. Fernandez, Felix and Ambrosio Isl. (Chile)"))
      return("Chile")
    if (country %in% c("Taiwan"))
      return("China")
    if (country %in% c("Greenland", "Faeroe Isl. (Denmark)"))
      return("Denmark")
    if (country %in% c("Ecuador (Galapagos Isl.)", "Galapagos Isl. (Ecuador)"))
      return("Ecuador")
    if (country %in% c("France (French Guiana)", "France (French Polynesia)", "France (Guadeloupe)",
                       "Guadeloupe", "France (Martinique)", "Martinique",
                       "France (Mayotte)", "France (New Caledonia)", "France (Réunion)",
                       "Amsterdam & St Paul Isl. (France)", "New Caledonia",
                       "Clipperton Isl. (France)", "Crozet Isl. (France)", "French Guiana", "Guadeloupe (France)",
                       "Kerguelen Isl. (France)", "Martinique (France)", "Mayotte (France)", "Mozambique Channel Isl. (France)",
                       "New Caledonia (France)", "Réunion (France)", "Saint Pierre & Miquelon (France)", "Tromelin Isl. (France)",
                       "Wallis & Futuna Isl. (France)", "Wallis and Futuna"))
      return("France")
    if (country %in% c("Haiti (Navassa Isl.)", "Navassa Isl. (Haiti)"))
        return("Haiti")
    if (country %in% c("Indonesia (Eastern)", "Indonesia (Western)"))
        return("Indonesia")
    if (country %in% c("Japan (main islands)", "Japan (outer islands)"))
        return("Japan")
    if (country %in% c("Korea (North)", "North Korea"))
        return("Korea, Rep.")
    if (country %in% c("Korea (South)", "South Korea"))
      return("Korea, Dem. Rep.")
    if (country %in% c("Malaysia (Peninsula East)", "Malaysia (Peninsula West)", "Malaysia (Sabah)", "Malaysia (Sarawak)"))
        return("Malaysia")
    if (country %in% c("Western Sahara (Morocco)", "Western Sahara"))
        return("Morocco")
    if (country %in% c("Leeward Netherlands Antilles", "Windward Netherlands Antilles"))
        return("Netherlands")
    if (country %in% c("Cook Isl. (New Zealand)", "Kermadec Isl. (New Zealand)", "New Zealand (Niue)", "New Zealand (Cook Isl.)",
                       "New Zealand (Tokelau)"))
      return("New Zealand")
    if (country %in% c("Bouvet Isl. (Norway)", "Norway (Svalbard Isl.)", "Jan Mayen Isl. (Norway)", "Svalbard Isl. (Norway)"))
      return("Norway")
    if (country %in% c("Azores Isl. (Portugal)", "Madeira Isl. (Portugal)", "Madeira"))
      return("Portugal")
    if (country %in% c("Russia (Baltic Sea, St. Petersburg)", "Russia (Barents Sea)", "Russia (Pacific)",
                       "Russia (Baltic Sea, Kaliningrad)", "Russia (Black Sea)", "Russia (Siberia)", "Russian Fed", "Russia"))
      return("Russian Federation")
    if (country %in% c("Saudi Arabia (Red Sea)", "Saudi Arabia (Persian Gulf)"))
        return("Saudi Arabia")
    if (country %in% c("Prince Edward Isl. (South Africa)"))
        return("South Africa")
    if (country %in% c("Canary Isl. (Spain)"))
      return("Spain")
    if (country %in% c("Turkey (Mediterranean Sea)", "Turkey (Black Sea)"))
      return("Turkey")
    if (country %in% c("Anguilla (UK)", "Anguilla", "Bermuda (UK)", "Bermuda",
                       "British Virgin Isl. (UK)",
                       "British Virgin Islands", "Cayman Isl. (UK)", "Cayman Islands",
                       "Chagos Archipel., Brit. Ind. Oc. Terr. (UK)", "Falkland Isl. (UK)",
                       "Montserrat (UK)", "Montserrat",
                       "Saint Helena (UK)", "Tristan da Cunha Isl. (UK)", "Ascension Isl. (UK)", "Bermuda (UK)",
                       "British Virgin Isl. (UK)", "Cayman Isl. (UK)", "Chagos Archipel., Brit. Ind. Oc. Terr. (UK)",
                       "Channel Isl. (UK)", "Falkland Isl. (UK)", "Pitcairn (UK)", "South Georgia & Sandwich Isl. (UK)",
                       "Turks & Caicos Isl. (UK)"))
      return("United Kingdom")
    if (country %in% c("Hawaii", "Alaska", "Alaska (USA)", "Guam (USA)", "Jarvis Isl. (USA)", "Johnston Atoll (USA)", "Northern Marianas (USA)",
                       "Puerto Rico", "Puerto Rico (USA)", "US Virgin Isl.", "Guam (USA)", "Hawaii Main Islands (USA)",
                       "Hawaii Northwest Islands (USA)", "Howland & Baker Isl. (USA)", "Jarvis Isl. (USA)",
                       "Johnston Atoll (USA)", "Palmyra Atoll & Kingman Reef (USA)", "United States, East Coast",
                       "United States, Gulf of Mexico", "United States, West Coast", "Wake Isl. (USA)", "USA"))
        return("United States")
    if (country %in% c("Gaza Strip"))
        return("West Bank and Gaza")

    return(as.character(country))
}

canonical2continent <- function(country) {
  if (country %in% c("Algeria", "Angola", "Benin", "Botswana", "Burkina", "Burundi", "Cameroon", "Cape Verde", "Central African Republic", "Chad", "Comoros", "Congo", "Congo, Democratic Republic of", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Ivory Coast", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe", "Canary Isl. (Spain)", "Congo, R. of", "Cote d'Ivoire", "France (Mayotte)", "France (Réunion)", "France (Mozambique Channel Isl.)"))
    return("Africa")

  if (country %in% c("Afghanistan", "Bahrain", "Bangladesh", "Bhutan", "Brunei", "Burma (Myanmar)", "Cambodia", "China", "East Timor", "India", "Indonesia", "Iran", "Iraq", "Israel", "Japan", "Jordan", "Kazakhstan", "Korea, North", "Korea, South", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Malaysia", "Maldives", "Mongolia", "Nepal", "Oman", "Pakistan", "Philippines", "Qatar", "Russian Federation", "Saudi Arabia", "Singapore", "Sri Lanka", "Syria", "Tajikistan", "Thailand", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Vietnam", "Yemen", "Hong Kong", "Malaysia (Peninsula East)", "Korea (South)", "Turkey (Black Sea)", "Saudi Arabia (Persian Gulf)", "Myanmar", "Taiwan", "Russia", "Andaman & Nicobar Isl. (India)", "Korea (North)"))
    return("Asia")

  if (country %in% c("Albania", "Andorra", "Armenia", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Georgia", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom", "Vatican City", "Norway (Svalbard Isl.)", "Channel Isl. (UK)"))
    return("Europe")

  if (country %in% c("Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada", "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "El Salvador", "Grenada", "Guatemala", "Haiti", "Honduras", "Jamaica", "Mexico", "Nicaragua", "Panama", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Trinidad and Tobago", "United States", "Alaska (USA)", "Greenland", "Haiti (Navassa Isl.)", "Puerto Rico (USA)", "France (Martinique)", "Turks & Caicos Isl. (UK)", "US Virgin Isl.", "France (Guadeloupe)", "Antigua & Barbuda", "British Virgin Isl. (UK)", "Anguilla (UK)", "Saint Vincent & the Grenadines", "Bermuda (UK)", "Cayman Isl. (UK)", "Montserrat (UK)"))
    return("North America")

  if (country %in% c("Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia", "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa", "Solomon Islands", "Tonga", "Tuvalu", "Vanuatu", "American Samoa", "Australia (Heard & McDonald Isl.)", "Hawaii", "Australia (Macquarie Isl.)", "Kermadec Isl. (New Zealand)", "Australia (Lord Howe Isl.)", "Marshall Isl.", "France (New Caledonia)", "Solomon Isl.", "Palmyra Atoll & Kingman Reef (USA)", "Brunei Darussalam", "Guam (USA)", "Howland & Baker Isl. (USA)", "France (French Polynesia)", "Australia (Christmas Isl.)", "Johnston Atoll (USA)", "Northern Marianas (USA)", "Cook Isl. (New Zealand)", "Timor Leste", "Australia (Norfolk Isl.)", "France (Wallis & Futuna Isl.)"))
    return("Oceania")

  if (country %in% c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela", "Falkland Isl. (UK)", "France (French Guiana)", "Netherlands Antilles (Windward)", "Trinidad & Tobago", "Chile (Desventuradas Isl.)", "Brazil (Trindade & Martin Vaz Isl.)"))
    return("South America")

  if (country %in% c("Chagos Archipel., Brit. Ind. Oc. Terr. (UK)", "Azores Isl. (Portugal)", "Chile (J. Fernandez, Felix and Ambrosio Isl.)", "Ecuador (Galapagos Isl.)", "Amsterdam & St Paul Isl. (France)", "Madeira Isl. (Portugal)", "Jarvis Isl. (USA)", "Australia (Cocos (Keeling) Isl.)", "Tristan da Cunha Isl. (UK)", "Chile (Easter Isl.)", "South Georgia & Sandwich Isl. (UK)", "Denmark (Faeroe Isl.)", "Jan Mayen Isl. (Norway)", "France (Kerguelen Isl.)"))
    return("Open Ocean")

  return(NA)
}
