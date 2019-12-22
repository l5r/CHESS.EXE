DRAW.ASM
========================
> Het *DRAW.ASM* bestand staat in voor alles wat getekend of aangeduid moet
> worden in het schaakspel. Hier worden dus de vakjes getekend, de figuren en
> de te aanduiden vakjes worden hier aangeduid.

Configuratie
------------------------
> Om het bord te tekenen is het noodzakelijk een paar zaken eerst te configureren
> zoals de *video_mode*, de *background* en het *palette*.

### Video_mode ###
Verwacht: *@@vm:dword*
Gebruikt: *eax*

> De procedure *video_mode* zal een meegegeven waarde in het eax register steken
> en wordt dan afgesloten met het interrupt 10h.

### Load_palette ###
Verwacht:
Gebruikt: *eax, edx*

*Te vervolledigen*

### Background ###
Verwacht: *@@color:dword*
Gebruikt: *eax, ecx, edi*

> De procedure *background* zal het video memory address inladen welk als een
> compile-time constante is gedefinieerd. Daarna worden de afmetingen berekend
> en in het ecx register gestopt. Vervolgens geven we de gewenste kleur in de
> vorm van een *BYTE PTR* mee aan het register al.

Bord tekenen
------------------------
> Wanneer we alles hebben geconfigureerd kunnen we beginnen met het effectief
> maken en tekenen van het bord. Dit houdt in dat we vierkanten moeten kunnen
> tekenen, deze moeten kunnen gebruiken om het bord te tekenen en tot slot de
> stukken kunnen tekenen bovenop deze vierkantjes.

### Draw_square ###
Verwacht: *@@color:dword, @@x:dword, @@y:dword*
Gebruikt: *eax, ebx, ecx, edx*

> De procedure zal de meegegeven x- en y-coördinaat gebruiken als linkerboven-
> hoek van het vierkant. Eerst wordt het beginpunt van het vierkant berekend
> en vervolgens worden er recursief lijnen getekend met een meegegeven waarde
> in *SQUARE_SIZE*. Deze constante gebruiken we dus ook voor de diepte.

### Draw_piece ###
Verwacht: *@@piece:dword, @@x:dword, @@y:dword*
Gebruikt: *eax, ebx, ecx, edx*

*Te vervolledigen*

### Draw_board ###
Verwacht:
Gebruikt: *eax, ebx, ecx, edx, esi*

> Deze procedure maakt twee lokale variabele aan: *@@x:dword, @@y:dword*. Deze
> worden bij elke iteratie veranderd en meegegeven aan *draw_square*. Er wordt
> ook een extra counter bijgehouden in de loop zodat we kunnen weten of we een
> wit of een grijs vakje moeten tekenen.

Selecteren
------------------------
> Naast het bord tekenen moet het schaakspel ook de mogelijkheid hebben vakjes
> te selecteren, dit omdat de speler wilt weten welke pion hij/zij vast heeft.
> Ook is dit handig voor de mogelijke zetten aan te duiden.

### Set_selection ###
Verwacht:
Gebruikt: *eax, ecx*

> Voor deze procedure introduceren we een paar globale variabelen die constant
> aangepast zullen worden. Zo hebben we *CURRENT_MODE*, die de huidige mode
> toont, dit kan of *mode_from* zijn of *mode_to*. Vervolgens hebben we de
> *FROM_X, FROM_Y en TO_X en TO_Y* variabelen. Hier zullen de coördinaten in-
> gestoken worden van de gewenste *from en to* vakjes. *set_selection* zal dus
> kijken of de variabelen al aangepast zijn en als dit niet is gebeurd dan
> zullen deze aangepast worden. De registers eax en ebx houden de *from en to*
> posities bij in *STRUC position* formaat.

### Move_selection ###
Verwacht: *@@dx:dword, @@dy:dword*
Gebruikt: *eax, ebx, ecx, edx*

*Te vervolledigen*

### Highlight_square ###
Verwacht: *@@x0:dword, @@y0:dword, @@color:dword*
Gebruikt: *eax, ebx, ecx, edx, edi*

> De procedure *highlight_square* lijkt sterk op de procedure *draw_square*.
> Dit omdat we in theorie een vierkant tekenen, het verschil hier is dat we
> enkel de rand tekenen in tegenstelling tot *draw_square*, waar we een vol,
> vierkant tekenden. Merk op dat we bij *draw_square* als x- en y-coördinaten
> pixels meegaven, hier geven we indices mee. (*highlight_square, 7, 7, 3h*).
> Het verschil in procedures zit hem in het naar beneden tekenen, hier tekenen
> geen lijn maar twee punten. Het eerste punt staat gelijk aan de x-coördinaat
> en het tweede punt staat gelijk aan de x-coördinaat opgeteld met de grote
> van een vierkant min een.

### Highlight_all ###
Verwacht:
Gebruikt: eax, ebx, ecx, esi, edi

> Dit is de procedure die alle te aanduiden vakjes gaat aanduiden door steeds
> *highlight_square* op te roepen met de juiste waarden.

### Reset_highlight ###
Verwacht:
Gebruikt:

> Deze procedure zet de globale variabelen in het datasegment terug naar de
> standaard waarden en de mode naar *mode_from* zodat we weten welke kleur
> we moeten gebruiken.

ENGINE.ASM
========================
> In het bestand *ENGINE.ASM* staat de motor van het spel. Dit bestand omvat
> de functionaliteit en regels die nodig zijn het spel te kunnen spelen. Alle
> logica zit hier dus in verwerkt.

Bewegen
------------------------
*Te vervolledigen*

### Do_move ###
Verwacht: *@@move_from:dword, @@move_to:dword*
Gebruikt: *eax, ebx, ecx, edx*

*Te vervolledigen*

Valideren
------------------------
> Het valideren van een stap is zeer belangrijk. Dit zorgt ervoor dat een pion
> niet zomaar op een andere pion kan gaan staan of over bepaalde pionnen kan
> springen. Dit is essentieel voor het maken van een schaakspel.

### Is_not_empty ###
Verwacht: *@@tile:dword*
Gebruikt: *ebx*

> Deze hulpprocedure zal kijken of het vakje met de meegegeven tegel bezet is
> of niet. Wanneer de er op die meegegeven tegen een pion staat, zal deze
> procedure een 1 in het eax register steken en teruggeven. Anders wordt er
> een nul in gestoken.

###Validate_chess_piece###
Verwacht: *@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword*
Gebruikt: *ebx, ecx*

> Deze procedures zijn gelijkaardig aan elkaar, de enige verschillen zitten
> in de logica. Elk schaakstuk heeft andere rechten en restricties. Daarom
> worden eerst alle regels afgegaan om te zien of het schaakstuk wel deze zet
> mag zetten. Vervolgens wordt er gekeken of er geen obstakels in de weg naar
> die zet zijn. Wanneer deze op het einde van de *validate* geraakt, betekent
> dit dat het een geldige zet is en wordt het eax register overschreven met
> waarde 1, anders met 0.

CHESS.ASM
========================
> De echte gameloop zit in dit bestand. Hier worden alle andere procedures
> opgeroepen om het spel te maken en worden de toetsenbord-instructies
> ingelezen. Afhankelijk van deze input wordt er steeds andere output
> gegenereerd.

Configuratie
------------------------
> Allereerst wordt de video mode op *13h* gezet, vervolgens word het kleuren-
> palette ingeladen. Daarnaast wordt ook de achtergrond ingesteld op zwart.
> Na de achtergrond te initialiseren kunnen we het bord tekenen en de start-
> positie aanduiden.

Gameloop
------------------------
> Nu we alles geïnitialiseerd hebben, kunnen we beginnen met input te lezen.
> Ten eerste wordt er gekeken of er een *keystroke* plaatsvindt. Wanneer dit
> niet is gebeurd, wordt de gameloop terug gestart en wordt er weer input
> ingelezen. Stel, er is een toets ingedrukt, dan zal deze check wel kloppen
> en zal de inhoud van deze toets opgevraagd worden. Vervolgens wordt deze
> vergeleken met de toetsen die ingedrukt kunnen worden. Als deze met geen
> toets overeenkomt betekent dit dat een verkeerde toets is ingedrukt en zal
> wederom, de gameloop herstarten. Anderzijds zal deze de procedure oproepen
> die geassocieerd is met die toets.

### Nivageren ###
> We kunnen navigeren over het schaakbord door de toetsen *w,a,d,s* te
> gebruiken. Deze zorgen ervoor dat je respectievelijk naar *boven, links, *
> *rechts en naar onder* navigeert.

### Selecteren ###
> Om een vakje te selecteren kan je de spatiebalk gebruiken of de enter toets.
> Eenmaal drukken zal het gewenste vakje selecteren en tweemaal drukken zal de
> geselecteerde pion (indien mogelijk) verplaatsen naar het gewenste vakje. 
