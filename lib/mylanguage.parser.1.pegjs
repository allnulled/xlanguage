{

	const initialTime = new Date();
	const phenomenons = {};
	const registerPhenomenon = function(name, valor) {
		phenomenons[name] = valor;
		return valor;
	};
	const decorateStats = function(output) {
		return {
			...output,
			tiempo: (new Date()-initialTime)/1000,
			fenomenos_identificados: phenomenons
		};
	};
}

Lenguaje = sentencias:Algo_completo* _* {return decorateStats({sentencias})}
Algo_completo = _* algo:Algo EOS {return Object.assign(algo, {es_sentencia: true})}

Algo = tipo_de_algo / algos_agrupados
algos_agrupados = "<" _* algo:Algo _* ">" {return algo}
tipo_de_algo = Algo_de_pregunta / Algo_de_fenomeno / Algo_de_valor / Algo_de_demostracion / Algo_habido / Algo_de_causalidad

Algo_de_causalidad = Algo_de_causalidad_frontal

Algo_de_causalidad_frontal = "si" _+ causa:Algo operador:operadores_de_causalidad_frontal consecuencia:Algo {return {tipo:"algo de causalidad frontal",causa,operador,consecuencia}}

Algo_de_demostracion = negacion:negacion_opcional? "se demuestra que" _+ referencia:Algo _+ (conjugacion_ser_presente) _+ valor:valor {return {tipo:"algo de demostracion",referencia,valor,negacion}}
Algo_de_valor = valor
Algo_habido = negacion:negacion_opcional? "hay" _+ habido:Algo {return {tipo:"algo habido",habido,negacion}}
Algo_de_pregunta = pregunta_de_que_algo / pregunta_de_por_que_algo / pregunta_de_que_conlleva_algo / pregunta_de_algo_ser / pregunta_de_algo
pregunta_de_algo = "¿" algo:Algo "?" {return {tipo:"pregunta de ",algo}}
pregunta_de_que_algo = "¿qué" _+ algo:Algo "?" {return {tipo:"pregunta de ",algo}}
pregunta_de_por_que_algo = "¿por qué" _+ algo:Algo "?" {return {tipo:"pregunta de ",algo}}
pregunta_de_que_conlleva_algo = "¿qué " conjugacion_conllevar_presente _+ algo:Algo "?" {return {tipo:"pregunta de ",algo}}
pregunta_de_algo_ser = "¿" algo:Algo _+ conjugacion_ser_presente _+ valor:valor "?" {return {tipo:"pregunta de ",algo,valor}}

valor = (determinacion / booleano / numero / homonimo / cualquier_cosa)

determinacion = grupos_de_determinacion / grupos_de_indeterminacion
grupos_de_determinacion = adjetivo_de_determinacion / "determinación" {return {tipo:"determinacion"}}
grupos_de_indeterminacion = adjetivo_de_indeterminacion / "indeterminación" {return {tipo:"indeterminacion"}}

nombre_de_determinacion = "determinaciones" / "determinación"
nombre_de_indeterminacion = "indeterminaciones" / "indeterminación"
adjetivo_de_determinacion = "determinados" / "determinadas" / "determinado" / "determinada"
adjetivo_de_indeterminacion = "indeterminados" / "indeterminadas" / "indeterminado" / "indeterminada"
cualquier_cosa = ("cualquier cosa") {return {tipo:"cualquier cosa"}}

booleano = booleano_de_verdad / booleano_de_falacia
booleano_de_verdad = adjetivo_de_verdad / "verdad" {return {tipo:"verdad"}}
booleano_de_falacia = adjetivo_de_falacia / "falacia" {return {tipo:"falacia"}}

adjetivo_de_verdad = ("verdaderos"/"verdaderas"/"verdadero"/"verdadera")
adjetivo_de_falacia = ("falaces"/"falaz")

numero = [0-9]+ ("." [0-9]+)? {return {tipo:"numero",numero:text()}}
homonimo = "como" _+ homonimo:Algo {return {tipo:"homonimo",homonimo}}

negacion_opcional = no:("no" _+)? {return !!no}

Algo_de_fenomeno = 
  prefijos:prefijos_de_fenomeno*
  fenomeno:(fenomeno/fenomeno_agrupado)
  sufijos:sufijos_de_fenomeno* {return {tipo:"fenomeno",prefijos,fenomeno,sufijos}}

fenomeno_agrupado = algos_agrupados

prefijos_de_fenomeno = prefijos_agrupados / prefijos_en_crudo

prefijos_agrupados = _* "<" _* prefijo:prefijos_de_fenomeno _* ">" {return prefijo}

prefijos_en_crudo = prefijo_de_adjetivo / 
	prefijo_de_articulo /
    prefijo_de_articulo_indefinido /
    prefijo_de_cercania /
    prefijo_de_mediania /
    prefijo_de_lejania /
    prefijo_de_cuantificacion /
	prefijo_de_suficiencia /
	prefijo_de_estimacion /
    prefijo_de_negacion

prefijo_de_adjetivo = adjetivos:lista_de_grupos_de_adjetivos _+ {return {tipo:"prefijo de adjetivo",adjetivos}}
prefijo_de_articulo = articulo:operadores_de_articulo _+ {return {tipo:"prefijo de articulo",articulo}}
prefijo_de_articulo_indefinido = articulo:operadores_de_articulo_indefinido _+ {return {tipo:"prefijo de articulo indefinido",articulo}}
prefijo_de_cercania = cercania:operadores_de_cercania _+ {return {tipo:"prefijo de cercania",cercania}}
prefijo_de_mediania = mediania:operadores_de_mediania _+ {return {tipo:"prefijo de mediania",mediania}}
prefijo_de_lejania = lejania:operadores_de_lejania _+ {return {tipo:"prefijo de lejania",lejania}}
prefijo_de_cuantificacion = cuantificacion:(operadores_de_cuantificacion) _+ {return {tipo:"prefijo de cuantificacion",cuantificacion}}
prefijo_de_suficiencia = suficiencia:(operadores_de_suficiencia) _+ {return {tipo:"prefijo de suficiencia",suficiencia}}
prefijo_de_estimacion = estimacion:(operadores_de_estimacion) _+ {return {tipo:"prefijo de estimacion",estimacion}}
prefijo_de_negacion = "no" _+ {return {tipo:"prefijo de negacion"}}

sufijos_de_fenomeno = sufijos_agrupados / sufijos_en_crudo

sufijos_agrupados = _* "<" _* sufijo:sufijos_de_fenomeno _* ">" {return sufijo}

sufijos_en_crudo = sufijo_de_adjetivo /
	sufijo_de /
    sufijo_si /
    sufijo_o /
    sufijo_y /
    sufijo_verbo /
    sufijo_ser_comparado /
    sufijo_ser_un_tipo_de /
    sufijo_de_porque /
    sufijo_de_por /
    sufijo_de_conllevar

sufijo_de_adjetivo = _+ adjetivos:lista_de_grupos_de_adjetivos {return {tipo:"sufijo de adjetivo",adjetivos}}
sufijo_de = _+ ("del"/"de") _+ de:Algo {return {tipo:"sufijo de",de}}
sufijo_si = _+ ("si") _+ si:Algo {return {tipo:"sufijo si",si}}
sufijo_o = _+ ("o") _+ o:Algo {return {tipo:"sufijo o",o}}
sufijo_y = _+ ("y") _+ y:Algo {return {tipo:"sufijo y",y}}
sufijo_verbo = _* negacion:negacion_opcional? "="+ ">" _* verbo:palabra complementos:complemento_del_verbo {return {tipo:"sufijo de verbo",verbo,complementos,negacion}}
sufijo_ser_comparado = _+ conjugacion_ser_presente _+ comparacion:terminos_de_comparacion _+ "que" _+ comparante:Algo {return {tipo:"sufijo de ser comparado",comparacion,comparante}}
sufijo_ser_un_tipo_de = _+ conjugacion_ser_presente " un tipo de" _+ tipo:Algo {return {tipo:"sufijo de ser tipo",tipo}}
sufijo_de_porque = _+ "porque" _+ porque:Algo {return {tipo:"sufijo de porque",porque}}
sufijo_de_por = _+ "por" _+ porque:Algo {return {tipo:"sufijo de por",por}}
sufijo_de_conllevar = _+ conllevar:conjugacion_conllevar_presente _+ porque:Algo {return {tipo:"sufijo de conllevar",conllevar}}

terminos_de_comparacion = operador:("más"/"menos") terminos:termino_comparador_adjetivo* {return {tipo:"terminos comparadores",operador,terminos}}
termino_comparador_adjetivo = _+ adjetivo:grupo_de_adjetivo {return {tipo:"adjetivo de comparacion",adjetivo}}

conjugacion_ser_presente = "soy"/"eres"/"es"/"somos"/"sois"/"son"
conjugacion_conllevar_presente = "conllevamos"/"conlleváis"/"conllevan"/"conllevo"/"conllevas"/"conlleva"

lista_de_grupos_de_adjetivos = lista_de_grupos_de_adjetivos_agrupados / lista_de_grupos_de_adjetivos_en_crudo 
lista_de_grupos_de_adjetivos_agrupados = _* "<" adjetivos:lista_de_grupos_de_adjetivos ">" {return adjetivos}
lista_de_grupos_de_adjetivos_en_crudo = inicial:grupo_de_adjetivo otros:continuacion_de_grupos_de_adjetivos* {return [].concat(inicial).concat(otros||[])}
continuacion_de_grupos_de_adjetivos = ("," (_*)) adjetivo:grupo_de_adjetivo {return adjetivo}
grupo_de_adjetivo = "@" adjetivo:palabra complemento:complemento_de_adjetivo? {return {tipo:"grupo de adjetivo",adjetivo,complemento}}
complemento_de_adjetivo = ":" _+ complemento:Algo {return {tipo:"complemento de adjetivo",complemento}}
complemento_del_verbo = (complemento_del_verbo_nominal / complemento_del_verbo_adjetival)*
complemento_del_verbo_nominal = ":" _+ complemento:Algo {return {tipo:"complemento de verbo nominal",complemento}}
complemento_del_verbo_adjetival = _+ complemento:lista_de_grupos_de_adjetivos {return {tipo:"complemento de verbo adjetival",complemento}}

fenomeno = fenomeno_de_cosa / fenomeno_identificado
fenomeno_de_cosa = "cosa" {return {tipo:"fenomeno de cosa"}}
fenomeno_identificado = "{" ((!"}").)* "}" {return registerPhenomenon(text(),{tipo:"fenomeno identificado",fenomeno:text()})}

palabra = [A-Za-z0-9_\-ÁÉÍÓÚáéíóúñäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ]+ {return text()}

operadores_de_articulo = 
	("los"/"las"/"la"/"el"/"lo") {return text()}
operadores_de_articulo_indefinido = 
	("unos"/"unas"/"una"/"uno"/"un") {return text()}
operadores_de_cercania = 
	("estos"/"estas"/"este"/"esta"/"esto") {return text()}
operadores_de_mediania = 
	("esos"/"esas"/"ese"/"esa"/"eso") {return text()}
operadores_de_lejania = 
	("aquellos"/"aquellas"/"aquel"/"aquella"/"aquello") {return text()}
operadores_de_cuantificacion = (
	"ningunos"/"ningunas"/"ninguno"/"ninguna"/"ningún"/
	"algunos"/"algunas"/"alguno"/"alguna"/"algún"/
    "otros"/"otras"/"otro"/"otra"/
	"todos"/"todas"/"todo"/"toda"/
	"cualquier"/"cualquiera"/"cada")
operadores_de_suficiencia = 
	("suficientes"/"suficiente"/"insuficientes"/"insuficiente")
operadores_de_estimacion = (
	"pocos"/"pocas"/"poco"/"poca"/
	"bastantes"/"bastante"/
	"muchos"/"muchas"/"mucho"/"mucha"/
	"demasiados"/"demasiadas"/"demasiado"/"demasiada")
operadores_de_causalidad_frontal = ((_+ "entonces" _+) / ("," _+)) {return text().trim()}
operadores_matematicos = ("*"/"+"/"-"/"/"/"%"/"^"/"&"/"|")

_ = space / line / tabulation / comment
space = " "
line = "\r\n" / "\n"
tabulation = "\t"
comment = "(" [^\)]* ")"
EOS = "."
EOF = !.