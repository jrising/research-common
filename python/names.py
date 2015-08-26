# Copied from ../R/names.R

def canonical2continent(country):
    if country in ["Algeria", "Angola", "Benin", "Botswana", "Burkina", "Burundi", "Cameroon", "Cape Verde", "Central African Republic", "Chad", "Comoros", "Congo", "Congo, Democratic Republic of", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Ivory Coast", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe", "Canary Isl. (Spain)", "Congo, R. of", "Cote d'Ivoire", "France (Mayotte)", "France (Réunion)", "France (Mozambique Channel Isl.)"]:
    return "Africa"

  if country in ["Afghanistan", "Bahrain", "Bangladesh", "Bhutan", "Brunei", "Burma (Myanmar)", "Cambodia", "China", "East Timor", "India", "Indonesia", "Iran", "Iraq", "Israel", "Japan", "Jordan", "Kazakhstan", "Korea, North", "Korea, South", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Malaysia", "Maldives", "Mongolia", "Nepal", "Oman", "Pakistan", "Philippines", "Qatar", "Russian Federation", "Saudi Arabia", "Singapore", "Sri Lanka", "Syria", "Tajikistan", "Thailand", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Vietnam", "Yemen", "Hong Kong", "Malaysia (Peninsula East)", "Korea (South)", "Turkey (Black Sea)", "Saudi Arabia (Persian Gulf)", "Myanmar", "Taiwan", "Russia", "Andaman & Nicobar Isl. (India)", "Korea (North)"]:
    return "Asia"

  if country in ["Albania", "Andorra", "Armenia", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Georgia", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom", "Vatican City", "Norway (Svalbard Isl.)", "Channel Isl. (UK)"]:
    return "Europe"

  if country in ["Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada", "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "El Salvador", "Grenada", "Guatemala", "Haiti", "Honduras", "Jamaica", "Mexico", "Nicaragua", "Panama", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Trinidad and Tobago", "United States", "Alaska (USA)", "Greenland", "Haiti (Navassa Isl.)", "Puerto Rico (USA)", "France (Martinique)", "Turks & Caicos Isl. (UK)", "US Virgin Isl.", "France (Guadeloupe)", "Antigua & Barbuda", "British Virgin Isl. (UK)", "Anguilla (UK)", "Saint Vincent & the Grenadines", "Bermuda (UK)", "Cayman Isl. (UK)", "Montserrat (UK)"]:
    return "North America"

  if country in ["Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia", "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa", "Solomon Islands", "Tonga", "Tuvalu", "Vanuatu", "American Samoa", "Australia (Heard & McDonald Isl.)", "Hawaii", "Australia (Macquarie Isl.)", "Kermadec Isl. (New Zealand)", "Australia (Lord Howe Isl.)", "Marshall Isl.", "France (New Caledonia)", "Solomon Isl.", "Palmyra Atoll & Kingman Reef (USA)", "Brunei Darussalam", "Guam (USA)", "Howland & Baker Isl. (USA)", "France (French Polynesia)", "Australia (Christmas Isl.)", "Johnston Atoll (USA)", "Northern Marianas (USA)", "Cook Isl. (New Zealand)", "Timor Leste", "Australia (Norfolk Isl.)", "France (Wallis & Futuna Isl.)"]:
    return "Oceania"

  if country in ["Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela", "Falkland Isl. (UK)", "France (French Guiana)", "Netherlands Antilles (Windward)", "Trinidad & Tobago", "Chile (Desventuradas Isl.)", "Brazil (Trindade & Martin Vaz Isl.)"]:
    return "South America"

  if country in ["Chagos Archipel., Brit. Ind. Oc. Terr. (UK)", "Azores Isl. (Portugal)", "Chile (J. Fernandez, Felix and Ambrosio Isl.)", "Ecuador (Galapagos Isl.)", "Amsterdam & St Paul Isl. (France)", "Madeira Isl. (Portugal)", "Jarvis Isl. (USA)", "Australia (Cocos (Keeling) Isl.)", "Tristan da Cunha Isl. (UK)", "Chile (Easter Isl.)", "South Georgia & Sandwich Isl. (UK)", "Denmark (Faeroe Isl.)", "Jan Mayen Isl. (Norway)", "France (Kerguelen Isl.)"]:
    return "Open Ocean"

  return None
}
