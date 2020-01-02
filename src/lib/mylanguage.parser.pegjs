{

const eventos = {
	"imprime": function(dato, padre) {
		try {
			console.log(dato.complementos.nominalidad.algo.texto);
		} catch(error) {}
	},
	"alerta": function(dato, padre) {
		try {
			return alert(dato.complementos.nominalidad.algo.texto);
		} catch(error) {}
	},
	"demanda": function(dato, padre) {
		try {
			return prompt(dato.complementos.nominalidad.algo.texto);
		} catch(error) {}
	}
};

const evaluarEventos = function(dato, padre = {}) {
	if(dato === null) {
		return;
	}
	if(dato.tipo === "sufijo de verbo indefinido") {
		if(dato.verbo in eventos) {
			return eventos[dato.verbo](dato);
		}
	} else {
		if(Array.isArray(dato)) {
			return dato.map(item => {
				return evaluarEventos(item, dato);
			});
		} else if(typeof dato === "object") {
			const parametros = Object.keys(dato).reduce((output,k) => {
				if(k === "tipo") {
					return output;
				}
				output[k] = dato[k];
				return output;
			}, {});
			return Object.keys(parametros).map(p => evaluarEventos(parametros[p], dato));
		}
	}
};


}

lenguaje                           = bloque:bloque {evaluarEventos(bloque);return bloque;}
bloque                             = _* bloque:algo_completa* _* {return {tipo:"bloque de lenguaje",bloque}}

algo_completa                      = sentencia:algo_complementable SIMB_EOS {return {tipo:"sentencia completa",...sentencia}}
algo_complementable                = (algo_complementable_sin_agrupar / algo_complementable_agrupado)
algo_complementable_sin_agrupar    = prefijos_unicos:prefijos_unicos prefijos:prefijo* algo:algo sufijos:sufijo* {return {prefijos:[].concat(prefijos_unicos).concat(prefijos),sufijos,algo}}
algo_complementable_agrupado       = SIMB_ABRE_AGRUPACION _* algo:algo_complementable _* SIMB_CIERRA_AGRUPACION {return algo}
algo_complementable_prespaciado    = _+ algo:algo_complementable {return algo}

prefijo                            = (prefijo_agrupado / prefijo_crudo)
prefijo_agrupado                   = SIMB_ABRE_AGRUPACION _* prefijo:prefijo_crudo _* SIMB_CIERRA_AGRUPACION {return prefijo}
prefijo_crudo                      = (prefijo_de_atributo / prefijo_de_determinante )
prefijo_de_atributo                = atribucion:atribucion _+ {return atribucion}
prefijo_de_determinante            = determinante:SIMB_DETERMINANTE _+ {return {tipo:"prefijo de determinante"}, determinante}
prefijo_de_asignacion              = SIMB_ABRE_ASIGNACION asignacion:algo_complementable SIMB_CIERRA_ASIGNACION _* {return {tipo:"prefijo de asignación",asignacion}}

prefijos_unicos                    = asignacion:prefijo_de_asignacion? si:prefijo_de_si_entonces? negacion:prefijo_de_negacion? hay:prefijo_de_hay? {return [].concat(asignacion ||[]).concat(si || []).concat(negacion || []).concat(hay || [])}
prefijo_de_si_entonces             = "si" _+ si:algo_complementable _+ "entonces" _+ {return {tipo:"prefijo de si entonces", si}}
prefijo_de_negacion                = SIMB_NO _+ {return {tipo:"prefijo de negación"}}
prefijo_de_hay                     = "hay" _+ {return {tipo:"prefijo de hay"}}

sufijo                             = (sufijo_agrupado/sufijo_crudo)
sufijo_agrupado                    = _* SIMB_ABRE_AGRUPACION _* sufijo_crudo _* SIMB_CIERRA_AGRUPACION
sufijo_crudo                       = (sufijo_de_atributo/sufijo_de_verbo/sufijo_de_y/sufijo_de_o/sufijo_de_de/sufijo_de_operacion_logica/sufijo_de_si)
sufijo_de_de                       = _* SIMB_DE _+ de:algo_complementable {return {tipo:"sufijo de de",de}}
sufijo_de_y                        = _* SIMB_Y _+ y:algo_complementable {return {tipo:"sufijo de y",y}}
sufijo_de_o                        = _* SIMB_O _+ o:algo_complementable {return {tipo:"sufijo de o",o}}
sufijo_de_si                       = _* SIMB_SI _+ condicion:algo_complementable {return {tipo:"sufijo de si condición",condicion}}
sufijo_de_atributo                 = _* atribucion:atribucion {return atribucion}
sufijo_de_verbo                    = (sufijo_de_verbo_definido / sufijo_de_verbo_indefinido)
sufijo_de_verbo_definido           = _+ negacion:(SIMB_NO  _+)? verbo:SIMB_VERBO_DEFINIDO complementos:predicado_de_verbo? {return {tipo:"sufijo de verbo definido",verbo,negacion,complementos}}
sufijo_de_verbo_indefinido         = negacion:(_* SIMB_NO  _*)? SIMB_VERBO_INDEFINIDO verbo:palabra complementos:predicado_de_verbo? {return {tipo:"sufijo de verbo indefinido",verbo,negacion,complementos}}
sufijo_de_operacion_logica         = _* operador:operador_logico _* algo:algo_complementable {return {tipo:"sufijo de operación lógica",operador,algo}}

algo                               = (algo_agrupado / algo_crudo)
algo_prespaciado                   = _+ algo:algo {return algo}
algo_agrupado                      = SIMB_ABRE_AGRUPACION _* algo:algo _* SIMB_CIERRA_AGRUPACION {return algo}
algo_crudo                         = (pregunta / afirmacion / valor)

pregunta                           = SIMB_ABRE_PREGUNTA pregunta:pregunta_tipo SIMB_CIERRA_PREGUNTA {return pregunta}
pregunta_tipo                      = (pregunta_booleana / pregunta_que / pregunta_por_que / pregunta_como / pregunta_donde / pregunta_cuando / pregunta_quien)
pregunta_booleana                  = algo:algo_complementable {return algo}
pregunta_que                       = SIMB_QUE_ACENTO que:algo_preguntado {return {tipo:"pregunta qué",que}}
pregunta_por_que                   = SIMB_POR_QUE_ACENTO por_que:algo_preguntado {return {tipo:"pregunta por qué",por_que}}
pregunta_como                      = SIMB_COMO_ACENTO como:algo_preguntado {return {tipo:"pregunta cómo",como}}
pregunta_donde                     = SIMB_DONDE_ACENTO donde:algo_preguntado {return {tipo:"pregunta dónde",donde}}
pregunta_cuando                    = SIMB_CUANDO_ACENTO cuando:algo_preguntado {return {tipo:"pregunta cuándo",cuando}}
pregunta_quien                     = SIMB_QUIEN_ACENTO quien:algo_preguntado {return {tipo:"pregunta quién",quien}}

algo_preguntado                    = (sufijo/algo_complementable_prespaciado)

afirmacion                         = (conjunto_fenomenico / fenomeno)

fenomeno                           = (fenomeno_en_crudo / fenomeno_agrupado)
fenomeno_en_crudo                  = SIMB_FENOMENO fenomeno:palabra {return {tipo:"fenómeno",fenomeno}}
fenomeno_agrupado                  = SIMB_ABRE_FENOMENO (!(SIMB_CIERRA_FENOMENO).)* SIMB_CIERRA_FENOMENO {return text()}
conjunto_fenomenico                = SIMB_ABRE_CONJUNTO_FENOMENICO _* fenomeno:bloque _* SIMB_CIERRA_CONJUNTO_FENOMENICO {return {tipo:"conjunto fenoménico",fenomeno}}

valor                              = (SIMB_VERDAD / SIMB_MENTIRA / SIMB_INDEFINIDO / SIMB_DEFINIDO / SIMB_NUMERO / SIMB_TEXTO / SIMB_CUALQUIER_COSA)

palabra                            = [A-Za-z0-9ÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÑñ\-\_]+ {return text()}

atribucion                         = (atribucion_agrupada / atribucion_sin_agrupar)
atribucion_agrupada                = SIMB_ABRE_AGRUPACION _* atribucion:atribucion _* SIMB_CIERRA_AGRUPACION {return atribucion}
atribucion_sin_agrupar             = SIMB_ATRIBUTO atribucion:palabra complementos:complementos_de_atribucion? {return {atribucion,complementos}}
atribucion_agrupada_prespaciada    = _+ atribucion:atribucion_agrupada {return atribucion}

lista_de_atribuciones              = atribucion_agrupada_prespaciada+

complementos_de_atribucion         = SIMB_INICIO_LISTA_ATRIBUCIONES _* algo:algo_complementable {return algo}

predicado_de_verbo                 = nominalidad:(algo_complementable_prespaciado)? adjetivalidad:(lista_de_atribuciones)? {return {tipo:"predicado de verbo",nominalidad,adjetivalidad}}

operador_logico                    = (SIMB_NUMERO / SIMB_MULTIPLICACION / SIMB_DIVISION / SIMB_SUMA / SIMB_RESTA / SIMB_RESIDUO / SIMB_RAIZ_DE / SIMB_POTENCIA / SIMB_DEFINICION / SIMB_IGUALACION / SIMB_Y_BINARIO / SIMB_O_BINARIO / SIMB_Y_LOGICO / SIMB_O_LOGICO / SIMB_VARIABLE / SIMB_DE_COMPARACION)

comentario_multilinea              = SIMB_ABRE_COMENTARIO (!(SIMB_CIERRA_COMENTARIO).)* SIMB_CIERRA_COMENTARIO {return {tipo:"comentario",comentario:text()}}

_                                  = ([\n\r\t ]/comentario_multilinea)
SIMB_ABRE_COMENTARIO               = ("[")
SIMB_CIERRA_COMENTARIO             = ("]")
SIMB_ABRE_CONJUNTO_FENOMENICO      = ("<{")
SIMB_CIERRA_CONJUNTO_FENOMENICO    = ("}>")
SIMB_ABRE_AGRUPACION               = ("(")
SIMB_CIERRA_AGRUPACION             = (")")
SIMB_ATRIBUTO                      = ("@")
SIMB_FENOMENO                      = ("#")
SIMB_ABRE_FENOMENO                 = ("{")
SIMB_CIERRA_FENOMENO               = ("}")
SIMB_ABRE_PREGUNTA                 = ("¿")
SIMB_CIERRA_PREGUNTA               = (&"?")
SIMB_ABRE_ASIGNACION               = ("(")
SIMB_CIERRA_ASIGNACION             = (":)")
SIMB_INICIO_LISTA_ATRIBUCIONES     = (":")
SIMB_QUE_ACENTO                    = ("qué")
SIMB_POR_QUE_ACENTO                = ("por qué")
SIMB_QUIEN_ACENTO                  = ("quién")
SIMB_COMO_ACENTO                   = ("cómo")
SIMB_DONDE_ACENTO                  = ("dónde")
SIMB_CUANDO_ACENTO                 = ("cuándo")
SIMB_NO                            = ("no")
SIMB_DE                            = ("del"/"de")
SIMB_Y                             = ("y"/"e")
SIMB_O                             = ("o"/"u")
SIMB_SI                            = ("si")
SIMB_DETERMINANTE                  = (SIMB_DETERMINANTE_ARTICULO/SIMB_DETERMINANTE_DISTANCIA/SIMB_DETERMINANTE_COMPLETITUD/SIMB_DETERMINANTE_PERTENENCIA)
SIMB_DETERMINANTE_ARTICULO         = (SIMB_DETERMINANTE_ARTICULO_DEF / SIMB_DETERMINANTE_ARTICULO_INDEF)
SIMB_DETERMINANTE_ARTICULO_DEF     = ("los"/"las"/"el"/"la"/"lo")
SIMB_DETERMINANTE_ARTICULO_INDEF   = ("unos"/"unas"/"uno"/"una"/"un")
SIMB_DETERMINANTE_DISTANCIA        = (SIMB_DETERMINANTE_CERCANIA / SIMB_DETERMINANTE_MEDIANIA / SIMB_DETERMINANTE_LEJANIA / SIMB_DETERMINANTE_OTRIDAD)
SIMB_DETERMINANTE_CERCANIA         = ("estos"/"estas"/"este"/"esta"/"esto")
SIMB_DETERMINANTE_MEDIANIA         = ("esos"/"esas"/"ese"/"esa"/"eso")
SIMB_DETERMINANTE_LEJANIA          = ("aquellos"/"aquellas"/"aquella"/"aquello"/"aquel")
SIMB_DETERMINANTE_OTRIDAD          = ("otros"/"otras"/"otra"/"otro")
SIMB_DETERMINANTE_COMPLETITUD      = (SIMB_DETERMINANTE_TOTALIDAD / SIMB_DETERMINANTE_ALGUNIDAD / SIMB_DETERMINANTE_NINGUNIDAD / SIMB_DETERMINANTE_DEMIASIA / SIMB_DETERMINANTE_MUCHIDAD / SIMB_DETERMINANTE_BASTANTIDAD / SIMB_DETERMINANTE_SUFICIENCIA / SIMB_DETERMINANTE_POQUIDAD / SIMB_DETERMINANTE_INSUFICIENCIA)
SIMB_DETERMINANTE_TOTALIDAD        = ("todos"/"todas"/"todo"/"toda")
SIMB_DETERMINANTE_ALGUNIDAD        = ("algunos"/"algunas"/"alguna"/"alguno"/"algún")
SIMB_DETERMINANTE_NINGUNIDAD       = ("ningunos"/"ningunas"/"ninguna"/"ninguno"/"ningún")
SIMB_DETERMINANTE_PERTENENCIA      = ("mis"/"mi"/"tus"/"tu"/"sus"/"su"/"nuestros"/"nuestro"/"vuestros"/"vuestro")
SIMB_DETERMINANTE_DEMIASIA         = ("demasiados"/"demasiadas"/"demasiado"/"demasiada")
SIMB_DETERMINANTE_MUCHIDAD         = ("muchos"/"muchas"/"mucho"/"mucha")
SIMB_DETERMINANTE_BASTANTIDAD      = ("bastantes"/"bastantas"/"bastante"/"bastanta")
SIMB_DETERMINANTE_SUFICIENCIA      = ("suficientes"/"suficiente")
SIMB_DETERMINANTE_POQUIDAD         = ("pocos"/"pocas"/"poco"/"poca")
SIMB_DETERMINANTE_INSUFICIENCIA    = ("insuficientes"/"insuficiente")
SIMB_EOS                           = (("."/"?") (_+/SIMB_EOF))
SIMB_EOF                           = (!(.))

SIMB_VERBO_HABER                   = ("hay"/"hemos"/"habéis"/"han"/"he"/"has"/"ha")

SIMB_VERBO_SER                     = ("soy"/"eres"/"es"/"somos"/"sois"/"son")

SIMB_VERBO_CAUSAR                  = ("causamos"/"causáis"/"causan"/"causo"/"causas"/"causa")
SIMB_VERBO_CONLLEVAR               = ("conllevamos"/"conlleváis"/"conllevan"/"conllevo"/"conllevas"/"conlleva")
SIMB_VERBO_IMPLICAR                = ("implicamos"/"implicáis"/"implican"/"implico"/"implicas"/"implica")
SIMB_VERBO_SIGNIFICAR              = ("significamos"/"significáis"/"significan"/"significo"/"significas"/"significa")

SIMB_VERBO_POSIBILITAR             = ("posibilitamos"/"posibilitáis"/"posibilitan"/"posibilito"/"posibilitas"/"posibilita")

SIMB_VERBO_DEFINIDO                = (SIMB_VERBO_SER / SIMB_VERBO_CAUSAR / SIMB_VERBO_CONLLEVAR / SIMB_VERBO_IMPLICAR / SIMB_VERBO_POSIBILITAR / SIMB_VERBO_SIGNIFICAR)
SIMB_VERBO_INDEFINIDO              = (_* "=>" _*)

SIMB_VERDAD                        = ("verdaderos"/"verdaderas"/"verdadero"/"verdadera"/"verdad")
SIMB_MENTIRA                       = ("falaz"/"falaces"/"falacias"/"falacia")
SIMB_INDEFINIDO                    = ("indefinidos"/"indefinidas"/"indefinido"/"indefinida")
SIMB_DEFINIDO                      = ("definidos"/"definidas"/"definido"/"definida")

SIMB_NUMERO                        = [0-9]+ ("." [0-9]+)? {return text()}
SIMB_TEXTO                         = StringLiteral
SIMB_MULTIPLICACION                = ("*")
SIMB_DIVISION                      = ("/")
SIMB_SUMA                          = ("+")
SIMB_RESTA                         = ("-")
SIMB_RESIDUO                       = ("%")
SIMB_RAIZ_DE                       = ("^/")
SIMB_POTENCIA                      = ("^")
SIMB_DEFINICION                    = (":="/"definido como")
SIMB_IGUALACION                    = ("=")
SIMB_Y_BINARIO                     = "&&"
SIMB_O_BINARIO                     = "||"
SIMB_Y_LOGICO                      = "&"
SIMB_O_LOGICO                      = "|"
SIMB_VARIABLE                      = "$"
SIMB_CUALQUIER_COSA                = "cualquier cosa"

SIMB_DE_COMPARACION                = (SIMB_MAYOR_QUE / SIMB_MENOR_QUE / SIMB_MAYOR_O_IGUAL_QUE / SIMB_MENOR_O_IGUAL_QUE / SIMB_IGUAL_QUE / SIMB_DISTINTO_QUE / SIMB_SIMILAR_A)

SIMB_MAYOR_QUE                     = ("más que"/"mayor que")
SIMB_MENOR_QUE                     = ("menos que"/"menor que")
SIMB_MAYOR_O_IGUAL_QUE             = ("más o igual que"/"más o igual a"/"mayor o igual que"/"mayor o igual a"/"igual o más que"/"igual o mayor que")
SIMB_MENOR_O_IGUAL_QUE             = ("menos o igual que"/"menos o igual a"/"menor o igual que"/"menor o igual a"/"igual o menos que"/"igual o menor que")
SIMB_IGUAL_QUE                     = ("igual que"/"igual a"/"lo mismo que")
SIMB_DISTINTO_QUE                  = ("distinto que"/"distinto a"/"diferente que"/"diferente a")
SIMB_SIMILAR_A                     = ("similar que"/"similar a"/"parecido a")
















StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { tipo: "texto", texto: chars.join("") };
    }
  / "'" chars:SingleStringCharacter* "'" {
      return {  tipo: "texto", texto: chars.join("") };
    }

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }

EscapeSequence
  = CharacterEscapeSequence
  / "0" !DecimalDigit { return "\0"; }
  / HexEscapeSequence
  / UnicodeEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter

SingleEscapeCharacter
  = "'"
  / '"'
  / "\\"
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; }

NonEscapeCharacter
  = !(EscapeCharacter / LineTerminator) SourceCharacter { return text(); }

EscapeCharacter
  = SingleEscapeCharacter
  / DecimalDigit
  / "x"
  / "u"

HexEscapeSequence
  = "x" digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
  = "u" digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

LineTerminator
  = [\n\r\u2028\u2029]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"

SourceCharacter
  = .

DecimalDigit
  = [0-9]

HexDigit
  = [0-9a-f]i