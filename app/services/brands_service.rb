class BrandsService < AttributeService
  BRANDS = {
    '22 Minutes To Midnight Cigars' => [
      '22 Minutes To Midnight Connecticut Radiante Cigars',
      '22 Minutes To Midnight Habano de Oro Cigars'
    ],
    '300 Hands' => [
      '300 Hands Connecticut By Southern Draw Cigars'
    ],
    '7-20-4 Cigars' => [
      '7-20-4 Hustler Cigars',
      '7-20-4 WK Series Cigars'
    ],
    '90 Millas Cigars' => [
      '90 Millas Habano Cigars',
      '90 Millas Connecticut Cigars',
      '90 Miles R.A. Nicaragua Limited Edition Cigars'
    ],
    'All Saints Cigars' => [
      'All Saints Dedicacion Habano Cigars',
      'All Saints Dedicacion Cigars',
      'All Saints Saint Francis Cigars',
      'All Saints Saint Francis Colorado Cigars'
    ],
    'Aganorsa' => [
      'Aganorsa JFR Cigars',
      'AGANORSA Leaf',
      'Aganorsa Leaf Aniversario Corojo Cigars',
      'Aganorsa Leaf Aniversario Maduro Cigars',
      'Aganorsa Leaf Connecticut Cigars',
      'Aganorsa Leaf Corojo Cigars',
      'Aganorsa Leaf Habano Cigars',
      'Aganorsa Leaf Maduro Cigars',
      'Aganorsa Leaf Signature Maduro Cigars',
      'Aganorsa Leaf Signature Selection Coroj',
      'Aganorsa Rare Leaf Cigars',
      'Aganorsa Leaf Signature Selection Corojo Cigars'
    ],
    'Aging Room Cigars' => [
      'agingroom',
      'Aging Room Bin No.2 Cigars',
      'Aging Room By Rafael Nodal Rare Collection Cigars',
      'Aging Room Quattro Connecticut Cigars',
      'Aging Room Quattro Maduro Cigars',
      'Aging Room Quattro Nicaragua Cigars',
      'Aging Room Quattro Original Cigars',
      'Aging Room Solera Corojo Cigars',
      'Aging Room Solera Maduro Cigars',
      'Aging Room Solera Shade Cigars'
    ],
    '' => [

    ],
    'Agio Meharis' => [
      'Agio Meharis',
      'Agio Meharis Cigarillos'
    ],
    'AJ Fernandez' => [
      'AJ Fernandez',
      'AJ Fernandez Cigars',
      'ajfernandez'
    ],
    'Al Capone' => [
      'Al Capone',
      'Al Capone Handmade',
      'Al Capone Cigars & Cigarillos'
    ],
    'Arturo Fuente Cigars' => [
      'arturofuente',
      'Arturo Fuente Cigars',
      'Arturo Fuente Sun Grown Cigars',
      'Arturo Fuente Don Carlos Cigars',
      'Arturo Fuente Especiales Cigars',
      'Arturo Fuente Hemingway Cigars',
      'Arturo Fuente',
      "Arturo Fuente Seleccion D'Oro Cigars"
    ],
    'Ashton Cigars' => [
      'ashton',
      'Ashton',
      'Ashton Cigars',
      'Ashton Aged Maduro Cigars',
      'Ashton Cabinet',
      'Ashton Cabinet Selection Cigars',
      'Ashton Cigar Cases',
      'Ashton Classic Cigars & Cigarillos',
      'Ashton Tobacco',
      'Ashton Estate Sun Grown Cigars',
      'Ashton Heritage Puro Sol Cigars',
      'Ashton Symmetry Cigars',
      'Ashton Virgin Sun Grown Cigars',
      'Ashton Small Cigars & Cigarillos',
      'Ashton Classic New Baby Cigars'
    ],
    'Asylum Cigars' => [
      'asylum',
      'Asylum',
      'Asylum Cigars',
      'Asylum 13 Cigars',
      'Asylum 13 Corojo Cigars',
      'Asylum 13 The OGRE Cigars',
      'Asylum 9 Cigars',
      'Asylum Insidious Cigars',
      'Asylum Lobotomy Cigars',
      'Asylum Lobotomy Corojo Cigars',
      'Asylum Nyctophilia Cigars',
      'Asylum Pandemonium Cigars',
      'Asylum Straight Jacket Cigars',
      'Asylum Limited Editions Cigars',
      'Asylum Premium Cigars'
    ],
    'Avo Cigars' => [
      'avo',
      'AVO',
      'Avo Cigars',
      'Avo Classic Cigars & Cigarillos',
      'Avo Heritage Cigars',
      'Avo Limited Editions Cigars',
      'Avo Maduro Cigars',
      'Avo Syncro Nicaragua Cigars',
      'Avo Syncro Nicaragua Cigars & Cigarillos',
      'Avo Syncro Nicaragua Fogata Cigars & Cigarillos',
      'Avo Syncro South America Ritmo Cigars',
      'Avo XO Cigars'
    ],
    'Bellas Artes Cigars' => [
      'Bellas Artes Maduro Cigars'
    ],
    'Baccarat Cigars' => [
      'baccarat',
      'Baccarat Cigars',
      'Baccarat Cigars & Cigarillos',
      'Baccarat Nicaragua Cigars'
    ],
    'Black Label Trading' => [
      'Black Label Trading Memento Mori Cigars',
      'Black Label Trading Royalty Cigars',
      'Black Label Trading Salvation Cigars'
    ],
    'Black Works Studio' => [
      'Black Works Studio Hyena Cigars',
      'Black Works Studio Killer Bee Cigars',
      'Black Works Studio NBK Cigars'
    ],
    "Blind Man's Bluff Cigars" => [
      "Blind Man's Bluff Connecticut Cigars",
      "Blind Man's Bluff Maduro Cigars",
      "Blind Man's Bluff Nicaragua Cigars"
    ],
    'Bolivar Cigars' => [
      'bolivar',
      'Bolivar Cigars',
      'Bolivar Cofradia By Lost & Found Cigars',
      'Bolivar Cofradia Cigars'
    ],
    'Brick House' => [
      'brickhouse',
      'Brick House',
      'Brick House Cigars',
      'Brick House Connecticut Cigars'
    ],
    'Cain Accessories And Samplers Cigars' => [
      'cain',
      'Cain Accessories And Samplers Cigars'
    ],
    'Caldwell Lost & Found Cigars' => [
      'Caldwell Cigars',
      'Caldwell Lost & Found Cigars',
      'Caldwell',
      'Caldwell Midnight Express Cigars',
      'Caldwell Savages Cigars'
    ],
    'Camacho' => [
      'camacho',
      'Camacho Cigars',
      'Camacho Triple Maduro Cigars',
      'Camacho American Barrel Aged Cigars',
      'Camacho BXP Connecticut Cigars',
      'Camacho Cigars',
      'Camacho Connecticut Cigars',
      'Camacho Corojo Cigars',
      'Camacho Criollo Cigars',
      'Camacho Ecuador Cigars',
      'Camacho Factory Unleashed Cigars',
      'Camacho Nicaragua Cigars',
      'Camacho Scorpion Cigars',
      'Camacho Scorpion Fumas Cigars',
      'Camacho Scorpion Sweet Tip Cigars'
    ],
    'CAO' => [
      'cao',
      'CAO',
      'CAO Flavours Cigars & Cigarillos',
      'CAO Tobacco',
      'CAO Cigars',
      'CAO 60 Cigars',
      'CAO Accessories And Samplers Cigars & Cigarillos',
      'CAO America Cigars',
      'CAO Arcana Cigars',
      'Cao Bones Cigar',
      'CAO Brazilia Cigars & Cigarillos',
      'CAO BX3 Cigars',
      'CAO Cameroon Cigars',
      'CAO Colombia Cigars',
      'CAO Consigliere Cigars',
      'CAO Gold Cigars & Cigarillos',
      'CAO Gold Maduro Cigars',
      'CAO Italia Cigars',
      'CAO LX2 Cigars',
      'CAO Maduro Cigars',
      'CAO MX2 Cigars',
      'CAO OSA Sol Cigars',
      'CAO Pilon Anejo Cigars',
      'CAO Pilon Cigars',
      'CAO Signature Series Cigars',
      'CAO Vision Cigars',
      'Cao Bones Cigars',
      'CAO CX2 Cigars'
    ],
    'Carlos Torano Signature Cigars' => [
      'carlostorano',
      'Carlos Torano Signature Cigars'
    ],
    'Casa Cuevas Cigars' => [
      'Casa Cuevas',
      'Casa Cuevas Cigars'
    ],
    'Casa de Garcia Cigars' => [
      'Casa de Garcia Cigars',
      'Casa de Garica',
      'Casa de Garcia'
    ],
    'Casa Magna Cigars' => [
      'casamagna',
      'Casa Magna Cigars'
    ],
    'Casa Fernandez' => [
      'Casa Fernandez Miami Aganorsa Cigars',
      'Casa Fernandez Miami Arsenio Oro Cigars',
      'Casa Fernandez Miami Cigars',
      'Casa Fernandez Miami Reserva Cigars',
      'Casa Fernandez New Cuba Connecticut'
    ],
    'Casa Turrent' => [
      'Casa Turrent 1880 Claro Cigars',
      'Casa Turrent 1880 Colorado Cigars',
      'Casa Turrent 1880 Maduro Cigars',
      'Casa Turrent 1880 Oscuro Cigars',
      'Casa Turrent Serie 1901 Cigars',
      'Casa Turrent Serie 1942 Cigars',
      'Casa Turrent Serie 1973 Cigars'
    ],
    'Cavalier Geneve' => [
      'Cavalier Cigars',
      'Cavalier Geneve',
      'Cavalier Geneve Black Series II Cigars',
      'Cavalier Geneve White Series Cigars',
      'Cavalier Geneve Black Series Cigars'
    ],
    'Charter Oak Cigars' => [
      'Charter Oak Cigars',
      'Charter Oak Habano Cigars'
    ],
    'Chillin Moose' => [
      'chillinmoose',
      'Chillin Moose',
      'Chillin Moose Bull Moose Cigars',
      "Chillin' Moose Cigars"
    ],
    'CLE' => [
      'cle',
      'CLE Cigars',
      'CLE Azabache Cigars',
      'CLE Chele Cigars',
      'CLE Connecticut Cigars',
      'CLE Corojo Cigars',
      'CLE Habano Cigars',
      'CLE Prieto Cigars'
    ],
    'Cohiba Cigars' => [
      'cohiba',
      'Cohiba Cigars',
      'Cohiba Cigars & Cigarillos',
      'Cohiba Black Cigars',
      'Cohiba Blue Cigars & Cigarillos',
      'Cohiba Connecticut Cigars',
      'Cohiba Macassar Cigars',
      'Cohiba Nicaragua Cigars',
      'Cohiba Serie M Cigars'
    ],
    'Cruz Real Cigars' => [
      'Cruz',
      'Cruz Real Cigars'
    ],
    'CroMagnon Cigars' => [
      'CroMagnon Aquitaine Cigars'
    ],
    'Crux Cigars' => [
      'Crux Bull & Bear Cigars',
      'Crux Du Connoisseur Cigars',
      'Crux Epicure Cigars',
      'Crux Epicure Maduro Cigars',
      'Crux Guild Cigars',
      'Crux Limitada Cigars'
    ],
    'Cuban Rounds Cigars' => [
      'Cuban Rounds',
      'Cuban Rounds Cigars'
    ],
    'Cusano Cigars' => [
      'cusano',
      'Cusano Cigars',
      'Cusano 18 Cigars',
      'Cusano CC Cigars',
      'Cusano M1 Cigars',
      'Cusano MC Cigars'
    ],
    'Davidoff' => [
      'davidoff',
      'Davidoff',
      'Davidoff Cigars',
      'Davidoff Cigarillos',
      'Davidoff Pipe Tobacco',
      'Davidoff Aniversario Series Cigars',
      'Davidoff Colorado Claro Cigars',
      'Davidoff Escurio Cigars',
      'Davidoff Grand Cru Series Cigars',
      'Davidoff Limited Edition Cigars',
      'Davidoff Millennium Cigars',
      'Davidoff Nicaragua Cigars',
      'Davidoff Yamasa Cigars',
      'Davidoff Signature Series Cigars & Cigarillos'
    ],
    'Debonaire Cigars' => [
      'debonaire',
      'Debonaire Cigars',
      'Debonaire Daybreak Cigars'
    ],
    'Diamond Crown Cigars' => [
      'diamondcrown',
      'Diamond Crown Cigars',
      'Diamond Crown Julius Caeser Cigars',
      'Diamond Crown Maximus Cigars',
      'Diamond Crown Pyramid'
    ],
    'Diesel Cigars' => [
      'diesel',
      'Diesel',
      'Diesel Cigars',
      'Diesel Disciple Cigars',
      'Diesel Esteli Puro Cigars',
      'Diesel Limited Edition Cigars',
      'Diesel Unlimited Cigars',
      'Diesel Whiskey Row Cigars',
      'Diesel Whiskey Row PX Sherry Cask Aged Cigars',
      "Diesel Fool's Errand Cigars",
      "Diesel Whiskey Row Founder's Collection Cigars"
    ],
    'Don Lino Cigars' => [
      'donlino',
      'Don Lino Habanitos Cigarillos',
      'Don Lino Africa Cigars',
      'Don Lino Maduro Cigars',
    ],
    'Don Mateo Cigars' => [
      'Don Mateo',
      'Don Mateo Cigars'
    ],
    'Don Pepin Garcia Cigars' => [
      'donpepingarcia',
      'Don Pepin Garcia',
      'Don Pepin Garcia Cigars',
      'Don Pepin Garcia Blue Cigars',
      'Don Pepin Garcia Cuban Classic Cigars',
      'Don Pepin Garcia Series JJ Cigars'
    ],
    'Don Tomas Cigars' => [
      'dontomas',
      'Don Tomas Clasico Cigars & Cigarillos',
      'Don Tomas Special Edition Connecticut Cigars',
      'Don Tomas Sun Grown Cigars'
    ],
    'Dunhill Cigars' => [
      'dunhill',
      'Dunhill Cigars'
    ],
    'Eiroa Cigars' => [
      'Eiroa Dark Natural Cigars',
      'Eiroa Maduro Cigars',
      'Eiroa The First 20 Years Cigars'
    ],
    'El Centurion Cigars' => [
      'elcenturion',
      'El Centurion Cigars'
    ],
    'El Rey del Mundo Cigars' => [
      'elreydelmundo',
      'El Rey Del Mundo By AJ Cigars',
      'El Rey del Mundo',
      'El Rey Del Mundo Cigars',
      'El Rey Del Mundo Naturals Cigars'
    ],
    'E.P. Carrillo Cigars' => [
      'E.P. Carrillo',
      'E.P. Carrillo Cigars',
      'EP Carrillo Retro 2021 Cigars'
    ],
    'Excalibur Cigars' => [
      'excalibur',
      'Excalibur Cigars',
      'Excalibur Black Cigars & Cigarillos',
      'Excalibur Cameroon Cigars',
      'Excalibur Cigars & Cigarillos',
      'Excalibur Dark Knight Cigars',
      'Excalibur Illusione Cigars'
    ],
    'Factory Smokes' => [
      'Factory 57 Cigars',
      'factory-smokes',
      'Factory Smokes',
      'Factory Smokes by Drew Estate',
      'Factory Smokes Sweet By Drew Es',
      'Factory Smokes Sweet By Drew Estate Cigars',
      'Factory Throwouts',
      'Factory Smokes CT. Shade By Drew Estate Cigars',
      'Factory Smokes Maduro By Drew Estate Cigars',
      'Factory Smokes Sungrown By Drew Estate Cigars',
      'Factory Throwouts Cigars '
    ],
    'Ferio Tego Cigars' => [
      'ferio-tego',
      'Ferio Tego Metropolican Habano Cigars',
      'Ferio Tego Metropolitan Connecticut Cigars',
      'Ferio Tego Metropolitan Host Cigars',
      'Ferio Tego Metropolitan Maduro Cigars',
      'Ferio Tego Timeless Panamericana Cigars',
      'Ferio Tego Timeless Prestige Cigars',
      'Ferio Tego Timeless Sterling Cigars',
      'Ferio Tego Timeless Supreme Cigars'
    ],
    'Flor de Las Antillas Cigars' => [
      'flordelasantillas',
      'Flor de Las Antillas Cigars'
    ],
    'Flor de Oliva Cigars' => [
      'flordeoliva',
      'Flor de Oliva Cigars',
      'Flor de Oliva Gold Cigars'
    ],
    'Fonseca By My Father Cigars' => [
      'fonseca',
      'Fonseca By My Father Cigars'
    ],
    'Foundry' => [
      'foundry',
      'Foundry'
    ],
    'Four Kicks Capa Especial by Crown' => [
      'Four Kicks By Crowned Heads Cigars',
      'Four Kicks Capa Especial by Crown',
      'Four Kicks Capa Especial by Crowned Heads Cigars'
    ],
    'Georges Reserve Cigars' => [
      'georgerico',
      'Georges Reserve Cigars'
    ],
    'Gilberto Cigars' => [
      'Gilberto Blanc Cigars',
      'Gilberto Cigars',
      'Gilberto Oliva Reserva Cigars'
    ],
    'Gispert Cigars' => [
      'gispert',
      'Gispert',
      'Gispert Cigars'
    ],
    'Gran Habano' => [
      'granhabano',
      'Gran Habano Cigars',
      'Gran Habano #1 Connecticut Cigars & Cigarillos',
      'Gran Habano 20th Aniversario Cigars',
      'Gran Habano #3 Habano Cigars & Cigarillos',
      'Gran Habano #5 Corojo Cigars & Cigarillos',
      'Gran Habano Accessories And Samplers Cigars',
      'Gran Habano GH2 Connecticut Cigars',
      'Gran Habano Gran Reserva #5 2010 Cigars',
      'Gran Habano La Conquista Cigars',
      'Gran Habano La Gran Fuma Cigars'
    ],
    'Griffins' => [
      'griffins',
      'Griffins',
      "Griffin's Cigars & Cigarillos"
    ],
    'Gurkha Cigars' => [
      'gurkha',
      'Gurkha Cigars',
      'Gurkha'
    ],
    'Guardian Of The Farm Cigars' => [
      'Guardian Of The Farm Cerberus Cigars',
      'Guardian Of The Farm Nightwatch Cigars'
    ],
    'Highclere Castle Cigars' => [
      'Highclere Castle Victorian Cigars'
    ],
    'Helix' => [
      'helix',
      'Helix',
      'Helix Cigars'
    ],
    'Henry Clay Cigars' => [
      'henryclay',
      'Henry Clay War Hawk Cigars'
    ],
    'Herrera Esteli' => [
      'herreraesteli',
      'Herrera Esteli Brazilian Maduro Cigars',
      'Herrera Esteli Habano Cigars',
      'Herrera Esteli Miami Cigars',
      'Herrera Esteli Norteno Cigars'
    ],
    'Ilegal Cigars' => [
      'Ilegal Connecticut Cigars',
      'Ilegal Habano Cigars',
      'Ilegal San Andres Cigars'
    ],
    'Indian Motorcycle Cigars' => [
      'indian-motorcycle',
      'Indian Motorcycle Cigars',
      'Indian Motorcycle Shade Cigars'
    ],
    'Isla del Sol Cigars' => [
      'isladelsol',
      'Isla del Sol Cigars',
      'Isla del Sol',
      'Isla Del Sol Maduro Cigars & Cigarillos',
      'Isla del Sol Sungrown Cigars & Cigarillos'
    ],
    'Java Cigars' => [
      'java',
      'Java Cigars',
      'Java Latte Cigars',
      'Java Mint Cigars',
      'Java Red Cigars',
      'Java by Drew Estate Cigars'
    ],
    'JFR' => [
      'JFR Connecticut Cigars',
      'JFR Lunatic Cigars'
    ],
    'La Aroma de Cuba' => [
      'laaromadecuba',
      'La Aroma de Cuba Cigars',
      'La Aroma de Cuba Mi Amor Cigars',
      'La Aroma de Cuba Mi Amor Reserva Cigars'
    ],
    'La Aurora' => [
      'laaurora',
      'La Aurora Cigars',
      'La Aurora 107 Cigars',
      'La Aurora 115th Anniversary Cigars',
      'La Aurora 1495 Brazil Cigars',
      'La Aurora 1495 Cigars',
      'La Aurora 1495 Connecticut Cigars',
      'La Aurora 1495 Nicaragua Cigars',
      'La Aurora 1903 Cameroon Cigars',
      'La Aurora 1962 Corojo Cigars',
      'La Aurora ADN Dominicano Cigars',
      'La Aurora Barrel Aged Cigars',
      'La Aurora Corojo Cigars',
      'La Aurora Especiales Cigars',
      'La Aurora Preferido Cigars',
      'La Aurora Preferidos Diamond Connecticut Broadleaf Cigars',
      'La Aurora Preferidos Emerald Ecuadorian Sungrown Cigars',
      'La Aurora Preferidos Gold Dominican Corojo Cigars',
      'La Aurora Preferidos Platinum Cameroon Cigars',
      'La Aurora Preferidos Sapphire Connecticut Shade Cigars',
      "La Aurora Preferidos Hors D'Age Cigars"
    ],
    'La Vieja Habana' => [
      'La Vieja Habana Brazilian Maduro Cigars & Cigarillos',
      'La Vieja Habana Cigarillos',
      'La Vieja Habana Connecticut Shade Cigars & Cigarillos',
      'La Vieja Habana Corojo Cigars'
    ],
    'La Estrella Cigars' => [
      'laestrellacubana',
      'La Estrella Cubana Connecticut Cigars',
      'La Estrella Cubana Habano Cigars'
    ],
    'La Fontana' => [
      'La Fontana',
      'La Fontana Vintage Cigars'
    ],
    'Last Call By AJ Fernandez' => [
      'Last Call By AJ Fernandez Cigars',
      'Last Call Maduro By AJ Fernandez Cigars'
    ],
    'Lunatic Cigars' => [
      'Lunatic Hysteria Barberpole Cigars',
      'Lunatic Hysteria By Aganorsa Cigars',
      'Lunatic Hysteria Perfecto Cigars'
    ],
    "Maker's Mark Cigars" => [
      "Maker's Mark Cigars & Cigarillos"
    ],
    'Mark Twain Cigars' => [
      'Mark Twain'
    ],
    'M By Macanudo Cigars' => [
      'M By Macanudo Flavors Cigars',
      'M Bourbon By Macanudo Cigars'
    ],
    'Montesino Cigars' => [
      'montecristo',
      'Montecristo 1935 Anniversary Cigars',
      'Monte by Montecristo Cigars',
      'Monte By Montecristo Cigars',
      'Montecristo',
      'Montecristo Classic Cigars',
      'Montecristo Epic Cigars',
      'Montecristo Espada',
      'Montecristo Espada Cigars',
      'Montecristo Espada Signature Cigars',
      'Montecristo Nicaragua Cigars',
      'Montecristo Platinum Cigars',
      'Montecristo Relentless Cigars',
      'Montecristo White Cigars',
      'Montecristo White Vintage Cigars',

    ],
    'National Brand Cigars' => [
      'National Brand Cigars',
      'National Brand Honduran'
    ],
    'Nat Sherman' => [
      'natsherman',
      'Nat Sherman'
    ],
    'Nestor Miranda' => [
      'nestormiranda',
      'Nestor Miranda Connecticut Collection Cigars',
      'Nestor Miranda Special Selection Cigars',
      'Nestor Miranda Special Selection Connecticut Cigars'
    ],
    'New World By AJ Fernandez' => [
      'newworld',
      'New World By AJ Fernandez',
      'New World by AJ Fernandez Cigars',
      'New World Connecticut by AJF Cigars',
      'New World Puro Especial by AJ Fernand',
      'New World Dorado Cigars',
      'New World Puro Especial by AJ Fernandez Cigars'
    ],
    'Nicaraguan Factory Selects Cigars' => [
      'Nicaraguan Factory Overruns',
      'Nicaraguan Factory Selects Cigars'
    ],
    'Nub Cigars' => [
      'nub',
      'Nub',
      'Nub Cafe Nuance Single Roast Cigars & Cigarillos',
      'Nub Connecticut Cigars',
      'Nub Dub by Oliva Cigars',
      'Nub Accessories and Samplers Cigars',
      'Nub Cafe Nuance Double Roast Cigars & Cigarillos',
      'Nub Cafe Nuance Triple Roast Cigars & Cigarillos',
      'Nub Cameroon Cigars',
      'Nub Habano Cigars',
      'Nub Maduro Cigars',
      'Nub Nuance Double Roast Cigars & Cigarillos',
      'Nub Nuance Single Roast Cigars & Cigarillos',
      'Nub Nuance Triple Roast Cigars & Cigarillos'
    ],
    'Omar Ortez Cigars' => [
      'Omar Ortez Original Cigars'
    ],
    'Onyx Cigars' => [
      'Onyx Bold Nicaragua Cigars',
      'Onyx Esteli Cigars',
      'Onyx Reserve Cigars'
    ],
    'Oscar Valladares Cigars' => [
      'Oscar Valladares 10th Anniversary Cigars',
      'Oscar Valladares Raw Dog Cigars'
    ],
    'Ozgener Family Cigars' => [
      'Ozgener Family Bosphorus Cigars'
    ],
    'Odyssey Cigars' => [
      'odyssey',
      'Odyssey Coffee Cigars',
      'Odyssey Connecticut Cigars',
      'Odyssey Full Cigars',
      'Odyssey Sweet Tip Cigars'
    ],
    'Oliva' => [
      'oliva',
      'Oliva Accessories and Samplers Cigars',
      'Oliva Baptiste Cigars',
      'Oliva Cain Cigars',
      'Oliva Cain Daytona Cigars',
      'Oliva Cigars',
      'Oliva Connecticut Reserve Cigars',
      'Oliva Master Blends 3 Cigars',
      'Oliva Serie G Cigars',
      'Oliva Serie G Maduro Cigars',
      'Oliva Serie O Cigars',
      'Oliva Serie O Maduro Cigars',
      'Oliva Serie V Cigars',
      'Oliva Serie V Cigars & Cigarillos',
      'Oliva Serie V Melanio Cigars'
    ],
    'Oliveros Cigars' => [
      'oliveros',
      'Oliveros Cigars'
    ],
    'Opus X' => [
      'Opus X',
      'Opus X'
    ],
    'Padron Cigars' => [
      'padron',
      'Padron',
      'Padron Cigars',
      'Padron 1964 Anniversary Maduro Cigars',
      'Padron 1964 Anniversary Natural Cigars',
      'Padron Damaso Cigars',
      'Padron Family Reserve Cigars',
      'Padron Serie 1926 Cigars'
    ],
    'Partagas Cigars' => [
      'partagas',
      'Partagas',
      'Partagas Cigars',
      'Partagas 1845 Clasico Cigars',
      'Partagas 1845 Extra Fuerte Cigars',
      'Partagas 1845 Extra Oscuro Cigars',
      'Partagas Anejo Cigars',
      'Partagas Black Label Cigars',
      'Partagas Cigars & Cigarillos',
      'Partagas Cortado Cigars',
      'Partagas Heritage Cigars',
      'Partagas Legend Cigars & Cigarillos',
      'Partagas Limited Reserve Decadas Cigars'
    ],
    'PDR Cigars' => [
      'PDR 1878 Dark Roast Cafe Cigars',
      'PDR 1878 santiago maduro Cigars',
      'PDR 1878 santiago natural Cigars',
      'PDR 1878 santiago natural Cigars',
      'PDR 1878 Santiago Sun Grown Cigars',
      'PDR A Flores Gran Reserva Corojo Cigars',
      'PDR A Flores Gran Reserva Desflorado Cigars',
      'PDR A Flores Gran Reserva Maduro Cigars',
      'PDR A Flores Gran Reserva Sun Grown Cigars',
      'PDR Cigars',
      'PDR El Criollito Cigars',
      'PDR El Trovador Cigars',
      'PDR Flores y Rodriguez 10th Anniversary Cigars',
      'PDR 1878 Santiago Oscuro Cigars'
    ],
    'Perdomo' => [
      'perdomo',
      'Perdomo Cigars',
      'Perdomo 20th Anniversary Connecticut Cigars',
      'Perdomo 20th Anniversary Maduro Cigars',
      'Perdomo 20th Anniversary Sun Grown Cigars',
      'Perdomo Accessories and Samplers Cigars',
      'Perdomo Champagne Cigars',
      'Perdomo Cuban Parejo Cigars',
      'Perdomo Double Aged Cigars',
      'Perdomo Double Aged Connecticut Cigars',
      'Perdomo Estate Seleccion Vintage Maduro Cigars',
      'Perdomo Estate Seleccion Vintage Sun Grown Cigars',
      'Perdomo Fresco Cigars',
      'Perdomo Fresco Sun Grown Cigars',
      'Perdomo Habano Cigars',
      'Perdomo Habano Connecticut Cigars',
      'Perdomo Inmenso Seventy Maduro Cigars',
      'Perdomo Inmenso Seventy Sun Grown Cigars',
      'Perdomo Lot 23 Cigars',
      'Perdomo Reserve 10th Anniversary Maduro Cigars',
      'Perdomo Reserve 10th Anniversary Sun Grown Cigars'
    ],
    'Perla del Mar Cigars' => [
      'Perla del Mar Maduro Cigars',
      'Perla del Mar Maduro Cigars',
      'Perla Del Mar Shade Cigars'
    ],
    'Pichardo Cigars' => [
      'Pichardo Clasico Cigars',
      'Pichardo Reserva Familiar Cigars'
    ],
    'Plasencia Cigars' => [
      'Plasencia Alma Del Campo Cigars',
      'Plasencia Alma Del Fuego Cigars',
      'Plasencia Alma Fuerte Cigars',
      'Plasencia Alma Fuerte Natural Cigars',
      'Plasencia Cosecha 146 Cigars',
      'Plasencia Cosecha 149 Cigars',
      'Plasencia Reserva Original Cigars'
    ],
    'Protocol Cigars' => [
      'Protocol blue Cigars',
      'Protocol Gold Themis Cigars',
      'Protocol Sir Robert Peel Cigars  '
    ],
    'Punch Cigars' => [
      'punch',
      'Punch Cigars',
      'Punch Limited Edition Cigars',
      'Punch Cigars & Cigarillos',
      'Punch Deluxe Cigars',
      'Punch Diablo Cigars & Cigarillos',
      'Punch Grand Cru Cigars',
      'Punch Knuckle Buster Cigars',
      'Punch Rare Corojo Cigars',
      'Punch Signature Cigars',
      'Punch Sucker Punch Cigars'
    ],
    'Quorum Cigars' => [
      'Quorum Classic Cigars',
      'Quorum Maduro Cigars',
      'Quorum Shade Cigars'
    ],
    'Quesada Cigars' => [
      'quesada',
      'Quesada Cigars'
    ],
    'Rocky Patel' => [
      'rockypatel',
      'Rocky Patel',
      'Rocky Patel Nicaraguan Cigars',
      'Rocky Patel 20th Anniversary Cigars',
      'Rocky Patel A.L.R. 2nd Edition Cigars',
      'Rocky Patel American Market Selection Cigars',
      'Rocky Patel American Market Selection Fumas Cigars',
      'Rocky Patel Cigar Smoking World Championship Cigars',
      'Rocky Patel Cuban Blend Cigars',
      'Rocky Patel Cuban Blend Fumas Cigars',
      'Rocky Patel Decade Cigars',
      'Rocky Patel Disciple Cigars',
      'Rocky Patel Factory Selects Edge Connecticut Cigars',
      'Rocky Patel Factory Selects Edge Corojo Cigars',
      'Rocky Patel Factory Selects Edge Habano Cigars',
      'Rocky Patel Factory Selects Edge Maduro Cigars',
      'Rocky Patel Grand Reserve Cigars',
      'Rocky Patel Hamlet 2020 Cigars',
      'Rocky Patel Honduran Classic Cigars',
      'Rocky Patel Juniors Cigars',
      'Rocky Patel Olde World Reserve Maduro Cigars',
      'Rocky Patel Private Cellar Cigars',
      'Rocky Patel Prohibition Cigars',
      'Rocky Patel Quarter Century Cigars',
      'Rocky Patel Rosado Fumas Cigars',
      'Rocky Patel Royale Cigars',
      'Rocky Patel San Andres Cigars',
      'Rocky Patel Sixty Cigars',
      'Rocky Patel Sumatra Cigars',
      'Rocky Patel Sun Grown Cigars',
      'Rocky Patel Sun Grown Fumas Cigars',
      'Rocky Patel Sun Grown Maduro Cigars',
      'Rocky Patel The Edge Cigars',
      'Rocky Patel The Edge Connecticut Cigars',
      'Rocky Patel Vintage 1990 Cigars',
      'Rocky Patel Vintage 1992 Cigars',
      'Rocky Patel Vintage 2006 Cigars',
      'Rocky Patel White Label Cigars',
      'Rocky Patel Xtreme Cigars'
    ],
    'Rojas Cigars' => [
      'Rojas Cigars',
      'Rojas Bluebonnets Cigars',
      'Rojas Statement Cigars',
      'Rojas Street Tacos Cigars',
      'Rojas Unfinished Business Cigars'
    ],
    'Romeo Y Julieta' => [
      'romeoyjulieta',
      'Romeo Y Julieta Cigars',
      'Romeo y Julieta',
      'Romeo',
      'Romeo y Julieta 1875 Cigars & Cigarillos',
      'Romeo y Julieta Capulet Cigars & Cigarillos',
      'Romeo y Julieta Montague Cigars &',
      'Romeo Y Julieta Cigars',
      'Romeo y Julieta Montague Cigars & Cigarillos',
      'Romeo',
      'Romeo By Romeo Y Julieta Cigars',
      'Romeo By Romeo y Julieta San Andres Cigars',
      'Romeo Y Julieta 1875 Nicaragua Cigars',
      'Romeo y Julieta Capulet Cigars',
      'Romeo Y Julieta Connecticut Nicaragua Cigars',
      'Romeo Y Julieta Esteli Cigars',
      'Romeo Y Julieta Eternal Cigars',
      'Romeo Y Julieta House Of Romeo Cigars',
      'Romeo y Julieta Mini Cigarillos',
      'Romeo y Julieta New Baby Cigars',
      'Romeo y Julieta Reserva Real Cabinet Seleccion Cigars',
      'Romeo y Julieta Reserva Real Cigars',
      'Romeo Y Julieta Reserva Real Nicaragua Cigars',
      'Romeo y Julieta Reserve Cigars',
      'Romeo y Julieta Verona Cigars',
      'Romeo y Julieta Vintage Cigars',
      'Romeo y Julieta Cigars'
    ],
    'Room 101 Cigars' => [
      'room101',
      'Room 101 Cigars',
      'Room101',
      'Room 101 Big Payback Cigars',
      'Room 101 Doomsayer Cigars',
      'Room 101 Doomsayer Cigars',
      'Room 101 Farce Maduro Cigars',
      'Room 101 Farce Original Cigars',
      'Room 101 Farce Connecticut Cigars'
    ],
    "San'Doro Cigars" => [
      "San'Doro Claro Cigars",
      'San Doro Colorado Cigars',
      'San Doro Maduro Cigars'
    ],
    'Sobremesa Cigars' => [
      'Sobremesa Brulee Cigars'
    ],
    'Solo Cafe Cigars' => [
      'Solo Cafe Dark Roast Cigars',
      'Solo Cafe Medium Roast Cigars',
      'Solo Cafe Natural Roast Cigars'
    ],
    'Saint Luis Rey Cigars' => [
      'saintluisrey',
      'Saint Luis Rey Cigars',
      'Saint Luis Rey Carenas Cigars',
      'Saint Luis Rey Serie G Cigars',
      'Saint Luis Rey Serie G Maduro Cigars'
    ],
    'Sancho Panza' => [
      'sanchopanza',
      'Sancho Panza',
      'Sancho Panza Cigars',
      'Sancho Panza Cigars & Cigarillos',
      'Sancho Panza Double Maduro Cigars',
      'Sancho Panza Extra Fuerte Cigars'
    ],
    'San Cristobal' => [
      'sancristobal',
      'San Cristobal',
      'San Cristobal Cigars',
      'San Cristobal Elegancia Cigars',
      'San Cristobal Ovation Cigars',
      'San Cristobal Quintessence Cigars',
      'San Cristobal Revelation Cigars'
    ],
    'San Lotano' => [
      'sanlotano',
      'San Lotano',
      'San Lotano Dominicano Cigars',
      'San Lotano Requiem Connecticut Cigars',
      'San Lotano Requiem Habano Cigars',
      'San Lotano Requiem Maduro Cigars',
      'San Lotano The Bull Cigars'
    ],
    'trinidad' => [
      'trinidad',
      'Trinidad Espiritu',
      'Trinidad y Cia',
      'ttttrinidad',
      'TTT Trinidad'
    ],
    'Undercrown' => [
      'undercrown',
      'Undercrown',
      'Undercrown Shade Cigars & Cigaril',
      'Undercrown Shade Cigars & Cigarillos'
    ],
    'VegaFina Cigars' => [
      'vegafina',
      'VegaFina Cigars'
    ],
    'Villiger' => [
      'villiger',
      'Villiger',
      'Villiger Cigars',
      'Villiger Cuellar Connecticut Kreme Cigars'
    ],
    'Zino' => [
      'zino',
      'Zino',
      'Zino Cigar Lighters',
      'Zino Cigarillos'
    ],
    'A Y C' => [
      'A Y C',
      'A Y C Grenadier'
    ],
    'BluntVille' => [
      'Bluntville',
      'BluntVille'
    ],
    'Cheyenne Cigars' => [
      'Cheyenne Cigars',
      'Cheyenne Heavy Weights Cigars',
      'Cheyenne Fine-Cut Tobacco'
    ],
    'De Nobili' => [
      'De Nobili',
      'De Nobili Cigars'
    ],
    'Djarum Cigars & Cigarillos' => [
      'Djarum Black Classic Natural Leaf Cigarillos',
      'Djarum Cigars & Cigarillos',
      'Djarum Vintage Cigarillos'
    ],
    'Double Diamond' => [
      'Double Diamond',
      'Double Diamond Cigars'
    ],
    'Dutch Masters Cigars' => [
      'Dutch Master',
      'Dutch Masters',
      'Dutch Masters Cigarillos Cigarillos',
      'Dutch Masters Cigars'
    ],
    'Garcia y Vega Cigars' => [
      'Garcia y Vega',
      'Garcia y Vega 1882 Cigars',
      'Garcia y Vega Cigars',
      'Garcia y Vega Cigars & Cigarillos',
      'Garcia y Vega Game Cigarillos Cigarillos',
      'Garcia y Vega Game Cigars',
      'Garcia y Vega Game Leaf Cigarillos',
      'Garcia y Vega Game Leaf Cigarillos Cigarillos'
    ],
    'Good Times' => [
      'Good Times',
      'Good Times 4ks Cigarillos',
      'Good Times Cigars',
      'Good Times #HD Cigarillos',
      'Good Times Sweet Woods',
      'Good Times Sweet Woods Cigarillos',
      'Good Stuff',
      'Good Times Sweet Woods Wraps',
    ],
    'Havana Honey' => [
      'Havana Honey',
      'Havana Honeys'
    ],
    'Hav a Tampa' => [
      'Hav a Tampa',
      'Hav-A-Tampa',
      'Hav-A-Tampa Cigars',
      'Hav-A-Tampa Jewels'
    ],
    'King Edward' => [
      'King Edward',
      'King Edward Cigars'
    ],
    'Marsh Wheeling' => [
      'Marsh Wheeling',
      'Marsh Wheeling Rough Cut',
      'Marsh Wheeling Cigars'
    ],
    'Optimo Cigars' => [
      'Optimo',
      'Optimo Cigarillos',
      'Optimo Cigars'
    ],
    'Panter' => [
      'Panter',
      'Panter Cigarillos'
    ],
    'Parodi Cigars' => [
      'Parodi',
      'Parodi Cigars'
    ],
    'Petri Cigars' => [
      'Petri',
      'Petri Cigars'
    ],
    'Phillies Cigars' => [
      'Phillies',
      'Phillies Cigars'
    ],
    'Pom Pom' => [
      'Pom Pom',
      'Pom Pom Cigarillos Cigarillos'
    ],
    'Prince Albert' => [
      'Prince Albert',
      'Prince Albert Cigars',
      'Prince Alberts Cigarillos',
      'Prince Albert Tobacco'
    ],
    'Principes Cigars' => [
      'Principe Chicos Cigarillos',
      'Principe Palmas Cigars',
      'Principes Cigars'
    ],
    'Ramrod Cigars' => [
      'Ramrod',
      'Ramrod Cigars'
    ],
    'Remington' => [
      'Remington',
      'Remington Filter Cigars'
    ],
    'Swisher Sweets Cigars' => [
      'Swisher Sweets',
      'Swisher Sweets BLK Cigarillos',
      'Swisher Sweets Cigars',
      'Swisher Sweets Cigars & Cigarillos',
      'Swisher Sweets Little Cigars'
    ],
    'Tiparillo' => [
      'Tiparillo',
      'Tiparillo Cigars & Cigarillos'
    ],
    'Tuscarora' => [
      'Tuscarora',
      'Tuscarora Cigars'
    ],
    'Villiger Cigars' => [
      'Villiger Cigars',
      'Villiger Cigars & Cigarillos',
      'Villiger Export Cigars'
    ],
    'White Owl' => [
      'White Owl',
      'White Owl 2 for 99c Cigarillos',
      'White Owl Cigars',
      'White Owl Cigars & Cigarillos',
      'White Owl Mini Cigarillos Cigarillo',
      'White Owl Mini Cigarillos Cigarillos'
    ],
    'Zig Zag' => [
      'Zig Zag',
      'Zig Zag Cigarillos'
    ],
    'Amphora' => [
      'Amphora',
      'Amphora Pipe Tobacco'
    ],
    'Arrowhead' => [
      'Arrowhead',
      'Arrowhead Pipe Tobacco'
    ],
    'Backwoods' => [
      'Backwoods',
      'Backwoods Pipe Tobacco',
      'Backwoods Cigars'
    ],
    'Balkan Sasieni' => [
      'Balkan Sasieni',
      'Balkan Sasieni Tobacco'
    ],
    'Borkum Riff' => [
      'Borkum Riff',
      'Borkum Riff Pipe Tobacco'
    ],
    'Carter Hall' => [
      'Carter Hall',
      'Carter Hall Pipe Tobacco'
    ],
    'Cherokee Pipe Tobacco' => [
      'Cherokee Fine-Cut Tobacco',
      'Cherokee Pipe Tobacco'
    ],
    'Dark Horse' => [
      'Dark Horse',
      'Dark Horse Pipe Tobacco'
    ],
    'Half & Half' => [
      'Half and Half',
      'Half & Half'
    ],
    'Kentuckys Best Pipe Tobacco' => [
      'Kentuckys Best Pipe Tobacco',
      'Kentucky Select Pipe Tobacco'
    ],
    'Mixture 79' => [
      'Mixture 79',
      'Mixture No. 79'
    ],
    'Orlik' => [
      'Orlik',
      'Orlik Pipe Tobacco'
    ],
    'Rio' => [
      'Rio',
      'Rio Pipe Tobacco'
    ],
    'Southern Steel' => [
      'Southern Steel',
      'Southern Steel Pipe Tobacco'
    ],
    'Sparrow' => [
      'Sparrow',
      'Sparrow Pipe Tobacco'
    ],
    'Sutliff' => [
      'Sutliff',
      'Sutliff Pipe Tobacco'
    ],
    'ACID' => [
      'ACID',
      'ACID Cigars',
      'acid',
      'Acid',
      'ACID Cigars & Cigarillos',
      'ACID Subculture Cigars'
    ],
    'Alec Bradley' => [
      'alecbradley',
      'Alec Bradley',
      'Alec Bradley 1633 Cigars',
      'Alec Bradley Cigars',
      'Alec Bradley Connecticut Cigars',
      'Alec Bradley Samplers and Accessories Cigars',
      'Alec Bradley American Classic Cigars',
      'Alec Bradley American Sun Grown Cigar',
      'Alec Bradley Black Market Cigars',
      'Alec Bradley Black Market Esteli Cigars',
      'Alec & Bradley Blind Faith Cigars',
      'Alec Bradley Connecticut Fumas Cigars',
      'Alec Bradley Coyol Cigars',
      'Alec Bradley Double Broadleaf Cigars',
      'Alec & Bradley Gatekeeper Cigars',
      'Alec Bradley Kintsugi Cigars',
      'Alec Bradley Magic Toast Cigars',
      'Alec Bradley Medalist Cigars',
      'Alec Bradley Prensado Cigars',
      'Alec Bradley Prensado Fumas Cigars',
      'Alec Bradley Prensado Lost Art Cigars',
      'Alec Bradley Project 40 Maduro Cigars',
      'Alec Bradley Sun Grown Cigars',
      'Alec Bradley Supervisor Selection Cigars',
      'Alec Bradley Tempus Cigars',
      'Alec Bradley Tempus Fumas Cigars',
      'Alec Bradley Tempus Nicaragua Cigars',
      'Alec Bradley Texas Lancero Cigars',
      'Alec Bradley The Lineage Cigars',
      'Alec Bradley The MAXX Cigars',
      'Alec Bradley American Sun Grown Cigars',
      'Alec Bradley Project 40 Cigars',
      'Alec Bradley American Classic Blend Cigars'
    ],
    'Ambrosia' => [
      'Ambrosia',
      'Ambrosia Cigars & Cigarillos'
    ],
    'Ave Maria' => [
      'Ave Maria',
      'Ave Maria Cigars',
      'Ave Maria Immaculata Cigars'
    ],
    'Baccarat' => [
      'Baccarat',
      'Baccarat Cigars'
    ],
    'Blitz' => [
      'Blitz',
      'Blitz Enterprises'
    ],
    'Captain Black' => [
      'Captain Black',
      'Captain Black Little Cigars'
    ],
    'Coil Art' => [
      'Coil Art',
      'Coil Master',
      'CoilART'
    ],
    'Colibri' => [
      'Colibri',
      'Colibri Cigar Cutters',
      'Colibri Cigar Lighters'
    ],
    'Criss Cross' => [
      'Criss Cross',
      'Criss Cross Heavy Weights Cigars'
    ],
    'Crowned Heads' => [
      'Crowned Heads',
      'Crowned Heads Cigars',
      'Crowned Heads Court Reserve Serie E Cigars'
    ],
    'Cuban Cigar' => [
      'Cuba Libre',
      'Cuban Aristocrat',
      'Cuban Cigar Factory',
      'Cuban Cigars Are Finally Coming To America...Maybe?',
      'Cuban Delights Corona Cigars',
      'Cuban Rounds Cigars',
      'Cuban Segundos',
      'Cuban Twist',
      'cubanaristocrat',
      'Cuba Aliados Cigars',
      'Cuban Aristocrat Connecticut Cigars',
      'Cuban Rounds Connecticut Cigars',
      'Cuban Aristocrat Habano Cigars',
      'Cuban Aristocrat Maduro Cigars'
    ],
    'Cuesta Rey Cigars' => [
      'Cuesta Rey Centro Fino Cigars',
      'Cuesta Rey Centenario Cigars & Cigarillos',
      'cuestarey'
    ],
    'Deadwood Tobacco Co.' => [
      'Deadwood Yummy Bitches Cigars & Cigarillos'
    ],
    'Dissident Cigars' => [
      'Dissident Bloc Cigars',
      'Dissident Soap Box Cigars',
      'Dissident Molotov Cigars',
      'Dissident Rant Cigars',
      'Dissident Rave Cigars',
      'Dissident Tirade Cigars'
    ],
    'Djarum Cigars' => [
      'Djarum Cigars & Cigarillos',
      'Djarum Filtered Cigars'
    ],
    'Drew Estate' => [
      'Drew Estate Cigars',
      'Drew Estate Pipe Collection by Tsuge',
      'drew-estate',
      'Drew Estate Limited Release Cigars'
    ],
    'Dunbarton Tobacco & Trust' => [
      'Dunbarton Tobacco & Trust',
      'Dunbarton Tobacco and Trust'
    ],
    'Dutch Cigars' => [
      'Dutch Delites',
      'Dutch Masters Cigars'
    ],
    'Eastern Standard Cigars' => [
      'Eastern Standard Sungrown Cigars'
    ],
    'Elie Bleu' => [
      'Elie Bleu',
      'Elie Bleu Cigar Cutters',
      'Elie Bleu Cigar Lighters'
    ],
    'Espinosa' => [
      'Espinosa Cigars',
      'Espinosa Crema Cigars',
      'Espinosa Habano Cigars',
      'Espinosa Knuckle Sandwich Cigars',
      'Espinosa Laranja Reserva Azulejo Cigars',
      'Espinosa Laranja Reserva Cigars',
      'Espinosa Laranja Reserva Escuro Cigars',
      'Espinosa Limited Releases Cigars',
      'Espinosa Murcielago Cigars',
      'Espinosa Reggae Cigars',
      'Espinosa Wasabi Cigars'
    ],
    'Famous Cigars' => [
      'Famous 365 Cigars',
      'Famous Dominican Selection 1000 Cigars',
      'Famous Dominican Selection 4000 Cigars',
      'Famous Dominican Selection 5000 Cigars',
      'Famous Exclusives Cigars',
      'Famous Nicaraguan Selection 1000 Cigars',
      'Famous Nicaraguan Selection 2000 Cigars',
      'Famous Nicaraguan Selection 3000 Cigars',
      'Famous Nicaraguan Selection 4000 Cigars',
      'Famous Nicaraguan Selection 5000 Cigars',
      'Famous Nicaraguan Selection 6000 Cigars',
      'Famous Nicaraguan Selection 7000 Cigars',
      'Famous Value Samplers Cigars',
      'Famous Vitolas Especiales Cigars',
      'Famous VSL Nicaragua Cigars'
    ],
    'Foundation Cigars' => [
      'Foundation Cigar Company',
      'Foundation Cigars'
    ],
    'FreeMax' => [
      'FreeMax',
      'Freemax'
    ],
    'H. Upmann' => [
      'H.Upmann',
      'H. Upmann Cigars',
      'hupmann',
      'H Upmann 1844 Anejo Cigars',
      'H. Upmann 1844 Classic Cigars',
      'H Upmann 1844 Reserve Cigars',
      'H. Upmann AJ Fernandez Cigars',
      'H. Upmann Banker Cigars',
      'H Upmann Connecticut Cigars',
      'H. Upmann Hispaniola By Jose Mendez Cigars',
      'H. Upmann Mogul Cigars',
      'H. Upmann Nicaragua AJ Fernandez Heritage Cigars',
      'H Upmann Sun Grown Cigars',
      'H Upmann Vintage Cameroon Cigars'
    ],
    'HVC Cigars' => [
      'HVC Cerro Maduro Cigars',
      'HVC 500 Years Anniversary Cigars',
      'HVC Black Friday Cigars',
      'HVC Edicion Especial 2018 Cigars',
      'HVC First Selection Broadleaf Limited Edition Cigars',
      'HVC Seleccion No.1 Maduro Cigars',
      'HVC Serie A Cigars',
      'HVC Vieja Consecha Cigars',
      'HVC Vieja Cosecha Cigars'
    ],
    'Hoyo Cigars' => [
      'Hoyo Cigars',
      'Hoyo de Monterrey',
      'hoyodemonterrey',
      'Hoyo de Monterrey Cigars',
      'Hoyo De Monterrey Epicure Seleccion Cigars',
      'Hoyo de Tradicion Cigars',
      'Hoyo La Amistad Black Cigars',
      'Hoyo La Amistad Gold Cigars'
    ],
    'Humidifiers' => [
      'Humidifier Solutions',
      'Humidifiers'
    ],
    'General Cigar' => [
      'General Cigar Company Accessories and Samplers Cigars',
      'General Cigar Freshness Pack Cigars',
      'General Honduran Bundles Cigars'
    ],
    'INCH By EPC Cigars' => [
      'INCH By EPC Cigars',
      'INCH Colorado by EPC Cigars',
      'INCH Nicaragua By E.P. Carrillo Cigars'
    ],
    'Illusione' => [
      'Illusione',
      'Illusione Cigars',
      'Illusione Classic Cruzado Cigars',
      'Illusione Epernay Cigars',
      'Illusione Garagiste Cigars',
      'Illusione Haut 10 Cigars',
      'Illusione La Grande Classe Cigars',
      'Illusione OneOff Cigars',
      "Illusione Fume D'Amour Cigars"
    ],
    'Inferno Cigars' => [
      'Inferno 3rd Degree Cigars',
      'Inferno Flashpoint Cigars',
      'Inferno Flashpoint Maduro Cigars',
      'Inferno Melt Cigars',
      'Inferno Scorch Cigars',
      'Inferno Singe Cigars'
    ],
    'Intemperance Cigars' => [
      'Intemperance BA XXI Cigars',
      'Intemperance EC XVIII Cigars',
      'Intemperance Whiskey Rebellion 1794'
    ],
    'JM' => [
        'JM',
        'JM Tobacco',
        "JM's Dominican Cigars",
        "JM's Dominican Connecticut Cigars"
    ],
    'JetLine' => [
      'Jet Line Lighters',
      'JetLine Cigar Cutters',
      'JetLine Cigar Lighters'
    ],
    'Joya de Nicaragua' => [
      'Joya de Nicaragua Joya Red Cigars & Cigarillos',
      'Joya de Nicaragua Antano 1970 Cigars',
      'Joya de Nicaragua Antano 1970 Gran Reserva Cigars',
      'Joya De Nicaragua Antano Connecticut Cigars',
      'Joya de Nicaragua Antano Dark Corojo Cigars',
      'Joya de Nicaragua Joya Cabinetta Cigars',
      'Joya De Nicaragua Joya Silver Cigars',
      'Joya De Nicaragua Cinco Decadas Cigars'
    ],
    'Kentucky' => [
      'Kentucky',
      'Kentucky Fire Cured',
      'Kentucky Fired Cured Sweets Cigars & Cigarillos',
      'Kentuckys Best Pipe Tobacco',
      'Kentucky Fire Cured Cigars & Cigarillos'
    ],
    'Kristoff' => [
      'Kristoff Accessories And Samplers Cigars',
      'Kristoff Cigars',
      'Kristoff Connecticut Cigars',
      'Kristoff Corojo Limitada Cigars',
      'Kristoff GC Signature Series Cigars',
      'Kristoff Habano Cigars',
      'Kristoff Maduro Cigars'
    ],
    "L'Atelier" => [
      "L'Atelier",
      "L'Atelier Cigars",
      "L'Atelier La Mission Cigars"
    ],
    'La Gloria Cigars' => [
      'La Gloria Cigars',
      'La Gloria Cubana',
      'lagloriacubana',
      'La Gloria Cubana 8th Street Cigars',
      'La Gloria Cubana Cigars & Cigarillos',
      'La Gloria Cubana Criollo De Oro Cigars',
      'La Gloria Cubana Esteli Cigars',
      'La Gloria Cubana Gilded Age Cigars',
      'La Gloria Cubana Medio Tiempo Cigars',
      'La Gloria Cubana Serie R Black Cigars',
      'La Gloria Cubana Serie R Black Maduro Cigars',
      'La Gloria Cubana Serie R Cigars',
      'La Gloria Cubana Serie R Esteli Cigars',
      'La Gloria Cubana Serie R Esteli Maduro Cigars',
      'La Gloria Cubana Serie RF Cigars',
      'La Gloria Cubana Serie S Cigars',
      'La Gloria Cubana Society Cigar Cigars',
      'La Gloria Cubana Spanish Press Cigars'
    ],
    'La Palina' => [
      'La Palina',
      'La Palina Cigars'
    ],
    'Lars Tetens Cigars' => [
      'lars-tetens',
      'Lars Tetens Cubagua Cigars',
      'Lars Tetens Phat Cigars',
      'Lars Tetens Serie D Cigars',
      'Lars Tetens SS Cigars',
      'Lars Tetens Sutton Place Cigars'
    ],
    'Leccia Cigars' => [
      'Leccia Cigars',
      'leccia'
    ],
    'Liga Privada' => [
      'Liga Privada No. 9 Cigars & Cigarillos',
      'ligaprivada',
      'Liga Privada T52 Cigars & Cigarillos',
      'Liga Privada Unico Serie Cigars',
      'Liga Undercrown Cigars',
      'Liga Undercrown Cigars & Cigarillos',
      'Liga Undercrown Sun Grown Cigars & Cigarillos'
    ],
    'Lotus' => [
      'Lotus',
      'Lotus Cigar Cutters',
      'Lotus Cigar Lighters'
    ],
    'Macanudo Cigars' => [
      'Macanudo Inspirado Red Cigars & Cigarillos',
      'macanudo',
      'Macanudo',
      'Macanudo 1968 Cigars',
      'Macanudo Cafe Cigars & Cigarillos',
      'Macanudo Cru Royale Cigars',
      'Macanudo Estate Reserve Cigars',
      'Macanudo Gold Label Cigars & Cigarillos',
      'Macanudo Inspirado Black Cigars',
      'Macanudo Inspirado Green Cigars',
      'Macanudo Inspirado Jamao Cigars',
      'Macanudo Inspirado Orange Cigars & Cigarillos',
      'Macanudo Inspirado White Cigars & Cigarillos',
      'Macanudo Maduro Cigars & Cigarillos',
      'Macanudo Vintage 1997 Cigars',
      'Macanudo Vintage 2006 Cigars',
      'Macanudo Vintage 2010 Cigars',
      ''
    ],
    'Maroma Cigars' => [
      'Maroma Cafe Cigars',
      'Maroma Dulce Cigars',
      'Maroma Natural Cigars'
    ],
    "Man O' War" => [
      "Man O' War",
      "Man O' War Cigars",
      "Man O' War Ruination Cigars"
    ],
    'Matilde Cigars' => [
      'Matilde Oscura Cigars',
      'Matilde Quadrata Cigars',
      'Matilde Renacer Cigars',
      'Matilde Serena Cigars'
    ],
    'Moya Cigars' => [
      'Moya Cigars',
      'MoyaRuiz Cigars'
    ],
    'My Father' => [
      'My Father Cigars',
      'myfather',
      'My Father Connecticut Cigars',
      'My Father La Gran Oferta Cigars',
      'My Father LA Opulencia Cigars',
      'My Father La Promesa Cigars',
      'My Father Le Bijou 1922 Cigars',
      'My Father The Judge Cigars'
    ],
    'Natural by Drew Estate' => [
      'Natural Larutan by Drew Estate Cigars',
      'Natural Larutan by Drew Estate Cigars & Cigarillos'
    ],
    'New Cuba Cigars' => [
      'New Cuba Connecticut Cigars',
      'New Cuba Corojo Cigars',
      'New Cuba Maduro Cigars'
    ],
    'Nicaraguan Cigars' => [
      'Nicaraguan Factory Selects Cigars',
      'Nicaraguan Nude Bundles',
      'Nicaraguan Overruns'
    ],
    'One Vape' => [
      'One Vape',
      'OneVape'
    ],
    'Opus  X' => [
      'Opus  X',
      'Opus X'
    ],
    'Padilla' => [
      'Padilla',
      'Padilla Cigars'
    ],
    'Palio Cigar' => [
      'Palio Cigar Cutters',
      'Palio Cigar Lighters'
    ],
    'Peterson Pipes' => [
      'Peterson Pipe Tobacco',
      'Peterson Pipes'
    ],
    'Project Sub-Ohm' => [
      'Project Sub-Ohm',
      'Project Sub-Ohm®'
    ],
    'Ramon' => [
      'Ramon Allones Cigars',
      'Ramon Bueso'
    ],
    'Rocky  Patel' => [
      'Rocky  Patel',
      'Rocky Patel',
      'Rocky Patel Burn',
      'Rocky Patel Cigars',
      'Rocky Patel Tavicusa Cigars'
    ],
    'S.T. Dupont' => [
      'S.T. Dupont',
      'S.T. Dupont Cigar Lighters'
    ],
    'SMOK' => [
      'SMOK',
      'SMOKTech'
    ],
    'Seleccion Cigars' => [
      'Seleccion By JR',
      'Seleccion Oscuro By EPC Cigars'
    ],
    'Smokers Cigars' => [
      'Smokers Choice Filtered Cigars',
      'Smokers Pride'
    ],
    'SnowWolf' => [
      'SnowWolf',
      'Snowwolf'
    ],
    'Southern Draw' => [
      'Southern Draw',
      'Southern Draw Cigars',
      'Southern Steel',
      'Southern Draw Firethorn Cigars',
      'Southern Draw Jacobs Ladder Ascension Cigars',
      'Southern Draw Jacobs Ladder Brimstone Cigars',
      'Southern Draw Jacobs Ladder Cigars',
      'Southern Draw Kudzu Cigars',
      'Southern Draw Manzanita Cigars',
      'Southern Draw Quickdraw Cigars',
      'Southern Draw Rose Of Sharon Cigars',
      'Southern Draw Rose Of Sharon Desert Rose Cigars',
      'Southern Draw Samplers Cigars'
    ],
    'Stinky' => [
      'Stinky',
      'Stinky Ashtray'
    ],
    'Svoë' => [
      'Svoe Mesto',
      'Svoë'
    ],
    'Tabak Especial' => [
      'Tabak Especial',
      'Tabak Especial Cigars & Cigarillos'
    ],
    'Tampa Trolleys Cigars' => [
      'Tampa Trolleys Cigars',
      'Tampa Trolleys by JC Newman'
    ],
    'Tatiana' => [
      'Tatiana',
      'Tatiana Miniature Cigars & Cigarillos',
      'Tatiana Tins Cigars & Cigarillos',
      'Tatiana Cigars',
      'Tatiana Classic Cigars',
      'Tatiana Dolce Cigarillos',
      'Tatiana La Vita Cigars',
      'Tatiana Mocha Cigars'
    ],
    'Tatuaje Cigars' => [
      'Tatuaje 10th Anniversary Cigars',
      'Tatuaje Black Cigars',
      'Tatuaje Broadleaf Collection Cigars',
      'Tatuaje Fausto Avion Cigars',
      'Tatuaje Fausto Cigars',
      'Tatuaje Havana VI Cigars',
      'Tatuaje Havana VI Verocu Cigars',
      'Tatuaje Limited Release Cigars',
      'Tatuaje Limited Release Cigars',
      'Tatuaje Miami Cigars',
      'Tatuaje Negociant Cigars',
      'Tatuaje Reserva Nicaragua Cigars',
      'Tatuaje Mexican Experiment ME II Cigars'
    ],
    'swag' => [
      'The SWAG',
      'swag',
    ],
    'Topper Cigars' => [
      'Topper Cigars',
      'Topper Handmade'
    ],
    'Trader Jacks' => [
      "Trader Jack's Cigars",
      'Trader Jacks'
    ],
    'Vector' => [
      'Vector',
      'Vector Cigar Lighters'
    ],
    'Vertigo' => [
      'Vertigo',
      'Vertigo Cigar Cutters',
      'Vertigo Cigar Lighters'
    ],
    'Visol Products' => [
      'Visol Cigar Cases',
      'Visol Cigar Lighters',
      'Visol Products'
    ],
    'Warped' => [
      'Warped',
      'Warped Cigars'
    ],
    'Xikar' => [
      'Xikar',
      'Xikar Ashtrays',
      'Xikar Butane',
      'Xikar Cases',
      'Xikar Cigar Cutters',
      'Xikar Cigar Lighters',
      'Xikar Cutters',
      'Xikar Lighters'
    ],
    '601' => [
      '601',
      '601 Cigars',
      '601 Blue Label Cigars',
      '601 Connecticut (Black) Cigars',
      '601 Kryptonite Cigars',
      '601 La Bomba Cigars',
      '601 Red Label Habano Cigars',
      '601 Steel Cigars'
    ],
    'La Flor Cigars' => [
      'La Flor Dominicana Limited Production Cigars',
      'laflordelcaney',
      'La Flor de Ynclan Cigars',
      'laflordominicana',
      'La Flor Dominicana',
      'La Flor Dominicana Accessories and Samplers Cigars',
      'La Flor Dominicana Air Bender Cigars',
      'La Flor Dominicana Cameroon Cabinet Cigars',
      'La Flor Dominicana Double Claro Cigars',
      'La Flor Dominicana Double Ligero Cigars',
      'La Flor Dominicana La Nox Cigars',
      'La Flor Dominicana Ligero Cabinet Oscuro Cigars',
      'La Flor Dominicana Ligero Cigars',
      'La Flor Dominicana Reserva Especial Cigars',
      'La Flor Dominicana Suave Cigars',
      'La Flor Dominicana Little Cigars & Cigarillos'
    ],
    'La Floridita Cigars' => [
      'La Floridita Fuerte Cigars',
      'La Floridita Gold Cigars',
      'La Floridita Limited Edition Cigars'
    ],
    'La Galera Cigars' => [
      'lagalera',
      'La Galera 1936 Box Pressed Cigars',
      'La Galera Connecticut Cigars',
      'La Galera Habano Cigars',
      'La Galera Maduro Cigars'
    ],
    'Talon' => [
      'Talon Filtered Cigars'
    ],
    'Yocan' => [
      'Yocan Vaporizers'
    ]
  }

  def self.merge!
    BRANDS.each do |brand, names|
      names.each do |name|
        Product.where('brand_name ILIKE ?', name).update_all brand_name: brand if brand != name
      end
    end
  end

  def self.brand_name(_brand_name)
    self.select_name _brand_name, BRANDS
  end
end
