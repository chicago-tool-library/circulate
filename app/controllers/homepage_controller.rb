class HomepageController < ApplicationController
  layout "homepage"

  def index
    @state_options =
      [
        "Alaska", "Alabama", "Arkansas", "American Samoa", "Arizona",
        "California", "Colorado", "Connecticut", "District of Columbia", "Delaware",
        "Florida", "Georgia", "Guam", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana",
        "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland", "Maine",
        "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "North Carolina",
        " North Dakota", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "Nevada",
        "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico",
        "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah","Virginia",
        "Virgin Islands", "Vermont", "Washington", "Wisconsin", "West Virginia", "Wyoming"
    ]
    @country_options =
      [
        "United States", "Afghanistan", "Albania", "Algeria", "Andorra",
        "Angola", "Anguilla", "Antigua &amp; Barbuda", "Argentina", "Armenia",
        "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain",
        "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda",
        "Bhutan", "Bolivia", "Bosnia &amp; Herzegovina", "Botswana", "Brazil",
        "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi",
        "Cambodia", "Cameroon", "Cape Verde", "Cayman Islands", "Chad", "Chile",
        "China", "Colombia", "Congo", "Cook Islands", "Costa Rica", "Cote D Ivoire",
        "Croatia", "Cruise Ship", "Cuba", "Cyprus", "Czech Republic", "Denmark",
        "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador",
        "Equatorial Guinea", "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands",
        "Fiji", "Finland", "France", "French Polynesia", "French West Indies", "Gabon",
        "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland",
        "Grenada", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea Bissau", "Guyana",
        "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia",
        "Iran", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan",
        "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Kyrgyz Republic", "Laos",
        "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania",
        "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives",
        "Mali", "Malta", "Mauritania", "Mauritius", "Mexico", "Moldova", "Monaco", "Mongolia",
        "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nepal", "Netherlands",
        "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria",
        "Norway", "Oman", "Pakistan", "Palestine", "Panama", "Papua New Guinea", "Paraguay",
        "Peru", "Philippines", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania",
        "Russia", "Rwanda", "Saint Pierre &amp; Miquelon", "Samoa", "San Marino", "Satellite",
        "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
        "Slovakia", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka",
        "St Kitts &amp; Nevis", "St Lucia", "St Vincent", "St. Lucia", "Sudan", "Suriname",
        "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania",
        "Thailand", "Timor L'Este", "Togo", "Tonga", "Trinidad &amp; Tobago", "Tunisia", "Turkey",
        "Turkmenistan", "Turks &amp; Caicos", "Uganda", "Ukraine", "United Arab Emirates",
        "United Kingdom", "Uruguay", "Uzbekistan", "Venezuela", "Vietnam", "Virgin Islands (US)",
        "Yemen", "Zambia", "Zimbabwe"
      ]
    @description_options =
      [
        "I’m starting or planning to open a lending library",
        "I manage or volunteer with an established lending library",
        "I’m just interested in learning more about Circulate",
      ]
  end

  def create
    HomepageMailer.with(homepage_params: homepage_params[:homepage]).inquiry.deliver_later

    redirect_to homepage_index_path
    # , flash: { success: "Your request has been submitted." }
  end

private

  def homepage_params
    params.permit(homepage: %i[name email city state country description inventory])
  end
end
