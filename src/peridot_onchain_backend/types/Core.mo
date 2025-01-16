import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {
    public type Timestamp = Time.Time;
    public type AppId = Nat;
    public type UserId = Principal;
    public type Version = Text;

    // Country =========================
    public type Country = {
        #AFG;
        #ALB;
        #DZA;
        #AND;
        #AGO;
        #ATG;
        #ARG;
        #ARM;
        #AUS;
        #AUT;
        #AZE;
        #BHS;
        #BHR;
        #BGD;
        #BRB;
        #BLR;
        #BEL;
        #BLZ;
        #BEN;
        #BTN;
        #BOL;
        #BIH;
        #BWA;
        #BRA;
        #BRN;
        #BGR;
        #BFA;
        #BDI;
        #CPV;
        #KHM;
        #CMR;
        #CAN;
        #CAF;
        #TCD;
        #CHL;
        #CHN;
        #COL;
        #COM;
        #COG;
        #CRI;
        #HRV;
        #CUB;
        #CYP;
        #CZE;
        #COD;
        #DNK;
        #DJI;
        #DMA;
        #DOM;
        #ECU;
        #EGY;
        #SLV;
        #GNQ;
        #ERI;
        #EST;
        #SWZ;
        #ETH;
        #FJI;
        #FIN;
        #FRA;
        #GAB;
        #GMB;
        #GEO;
        #DEU;
        #GHA;
        #GRC;
        #GRD;
        #GTM;
        #GIN;
        #GNB;
        #GUY;
        #HTI;
        #HND;
        #HUN;
        #ISL;
        #IND;
        #IDN;
        #IRN;
        #IRQ;
        #IRL;
        #ISR;
        #ITA;
        #CIV;
        #JAM;
        #JPN;
        #JOR;
        #KAZ;
        #KEN;
        #KIR;
        #KWT;
        #KGZ;
        #LAO;
        #LVA;
        #LBN;
        #LSO;
        #LBR;
        #LBY;
        #LIE;
        #LTU;
        #LUX;
        #MDG;
        #MWI;
        #MYS;
        #MDV;
        #MLI;
        #MLT;
        #MHL;
        #MRT;
        #MUS;
        #MEX;
        #FSM;
        #MDA;
        #MCO;
        #MNG;
        #MNE;
        #MAR;
        #MOZ;
        #MMR;
        #NAM;
        #NRU;
        #NPL;
        #NLD;
        #NZL;
        #NIC;
        #NER;
        #NGA;
        #PRK;
        #MKD;
        #NOR;
        #OMN;
        #PAK;
        #PLW;
        #PSE;
        #PAN;
        #PNG;
        #PRY;
        #PER;
        #PHL;
        #POL;
        #PRT;
        #QAT;
        #ROU;
        #RUS;
        #RWA;
        #KNA;
        #LCA;
        #VCT;
        #WSM;
        #SMR;
        #STP;
        #SAU;
        #SEN;
        #SRB;
        #SYC;
        #SLE;
        #SGP;
        #SVK;
        #SVN;
        #SLB;
        #SOM;
        #ZAF;
        #KOR;
        #SSD;
        #ESP;
        #LKA;
        #SDN;
        #SUR;
        #SWE;
        #CHE;
        #SYR;
        #TJK;
        #TZA;
        #THA;
        #TLS;
        #TGO;
        #TON;
        #TTO;
        #TUN;
        #TUR;
        #TKM;
        #TUV;
        #UGA;
        #UKR;
        #ARE;
        #GBR;
        #USA;
        #URY;
        #UZB;
        #VUT;
        #VAT;
        #VEN;
        #VNM;
        #YEM;
        #ZMB;
        #ZWE;
    };

    // Language =========================
    public type Language = {
        #AAR; // Afar
        #ABK; // Abkhazian
        #AFR; // Afrikaans
        #AKA; // Akan
        #ALB; // Albanian
        #AMH; // Amharic
        #ARA; // Arabic
        #ARG; // Aragonese
        #ARM; // Armenian
        #ASM; // Assamese
        #AVA; // Avaric
        #AVE; // Avestan
        #AYM; // Aymara
        #AZE; // Azerbaijani
        #BAK; // Bashkir
        #BAM; // Bambara
        #BAS; // Basque
        #BEL; // Belarusian
        #BEN; // Bengali
        #BIH; // Bihari languages
        #BIS; // Bislama
        #BOD; // Tibetan
        #BOS; // Bosnian
        #BRE; // Breton
        #BUL; // Bulgarian
        #CAT; // Catalan
        #CES; // Czech
        #CHA; // Chamorro
        #CHE; // Chechen
        #CHI; // Chinese
        #CHV; // Chuvash
        #COR; // Cornish
        #COS; // Corsican
        #CRE; // Cree
        #CYM; // Welsh
        #DAN; // Danish
        #DEU; // German
        #DIV; // Divehi
        #DZO; // Dzongkha
        #ELL; // Greek
        #ENG; // English
        #EPO; // Esperanto
        #EST; // Estonian
        #EUS; // Basque
        #EWE; // Ewe
        #FAO; // Faroese
        #FAS; // Persian
        #FIJ; // Fijian
        #FIN; // Finnish
        #FRA; // French
        #FRY; // Western Frisian
        #FUL; // Fulah
        #GLA; // Gaelic
        #GLE; // Irish
        #GLG; // Galician
        #GLV; // Manx
        #GRN; // Guarani
        #GUJ; // Gujarati
        #HAT; // Haitian
        #HAU; // Hausa
        #HEB; // Hebrew
        #HER; // Herero
        #HIN; // Hindi
        #HMO; // Hiri Motu
        #HRV; // Croatian
        #HUN; // Hungarian
        #HYE; // Armenian
        #IBO; // Igbo
        #IDO; // Ido
        #III; // Sichuan Yi
        #IKU; // Inuktitut
        #ILE; // Interlingue
        #INA; // Interlingua
        #IND; // Indonesian
        #IPK; // Inupiaq
        #ISL; // Icelandic
        #ITA; // Italian
        #JAV; // Javanese
        #JPN; // Japanese
        #KAL; // Kalaallisut
        #KAN; // Kannada
        #KAS; // Kashmiri
        #KAT; // Georgian
        #KAU; // Kanuri
        #KAZ; // Kazakh
        #KHM; // Central Khmer
        #KIK; // Kikuyu
        #KIN; // Kinyarwanda
        #KIR; // Kirghiz
        #KOM; // Komi
        #KON; // Kongo
        #KOR; // Korean
        #KUA; // Kuanyama
        #KUR; // Kurdish
        #LAO; // Lao
        #LAT; // Latin
        #LAV; // Latvian
        #LIM; // Limburgan
        #LIN; // Lingala
        #LIT; // Lithuanian
        #LTZ; // Luxembourgish
        #LUB; // Luba-Katanga
        #LUG; // Ganda
        #MAH; // Marshallese
        #MAL; // Malayalam
        #MAR; // Marathi
        #MKD; // Macedonian
        #MLG; // Malagasy
        #MLT; // Maltese
        #MON; // Mongolian
        #MRI; // Maori
        #MSA; // Malay
        #MYA; // Burmese
        #NAU; // Nauru
        #NAV; // Navajo
        #NBL; // South Ndebele
        #NDE; // North Ndebele
        #NDO; // Ndonga
        #NEP; // Nepali
        #NLD; // Dutch
        #NNO; // Norwegian Nynorsk
        #NOB; // Norwegian Bokmål
        #NOR; // Norwegian
        #NYA; // Nyanja
        #OCI; // Occitan
        #OJI; // Ojibwa
        #ORI; // Oriya
        #ORM; // Oromo
        #OSS; // Ossetian
        #PAN; // Panjabi
        #PLI; // Pali
        #POL; // Polish
        #POR; // Portuguese
        #PUS; // Pushto
        #QUE; // Quechua
        #ROH; // Romansh
        #RON; // Romanian
        #RUN; // Rundi
        #RUS; // Russian
        #SAG; // Sango
        #SAN; // Sanskrit
        #SIN; // Sinhala
        #SLK; // Slovak
        #SLV; // Slovenian
        #SME; // Northern Sami
        #SMO; // Samoan
        #SNA; // Shona
        #SND; // Sindhi
        #SOM; // Somali
        #SOT; // Southern Sotho
        #SPA; // Spanish
        #SQI; // Albanian
        #SRD; // Sardinian
        #SRP; // Serbian
        #SSW; // Swati
        #SUN; // Sundanese
        #SWA; // Swahili
        #SWE; // Swedish
        #TAH; // Tahitian
        #TAM; // Tamil
        #TAT; // Tatar
        #TEL; // Telugu
        #TGK; // Tajik
        #TGL; // Tagalog
        #THA; // Thai
        #TIR; // Tigrinya
        #TON; // Tonga
        #TSN; // Tswana
        #TSO; // Tsonga
        #TUK; // Turkmen
        #TUR; // Turkish
        #TWI; // Twi
        #UIG; // Uighur
        #UKR; // Ukrainian
        #URD; // Urdu
        #UZB; // Uzbek
        #VEN; // Venda
        #VIE; // Vietnamese
        #VOL; // Volapük
        #WLN; // Walloon
        #WOL; // Wolof
        #XHO; // Xhosa
        #YID; // Yiddish
        #YOR; // Yoruba
        #ZHA; // Zhuang
        #ZHO; // Chinese
        #ZUL; // Zulu
    };

    // For uniform error handling
    public type ApiResponse<T> = Result.Result<T, ApiError>;
    public type ApiError = {
        #NotFound : Text;
        #AlreadyExists : Text;
        #InvalidInput : Text;
        #StorageError : Text;
        #Unauthorized : Text;
        #InternalError : Text;
        #ValidationError : Text;
    };
};
