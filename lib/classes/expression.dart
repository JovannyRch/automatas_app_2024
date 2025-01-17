import 'package:automatas_2024/classes/converter.dart';

class Expresion {
  String infija;
  String postfija = "";
  List<String> operadores;
  Map precedencia;
  List<String> alfabeto = [];
  Map automatasBase = Map();
  late Automata thompson;
  late Automata nfa;
  late Automata dfa;
  late Automata dfaMin;
  late Automata dfaMinSinVacio;

  Expresion({
    required this.infija,
    required this.operadores,
    required this.precedencia,
  }) {
    this.postfija = this.getPostfix();
    this.alfabeto.sort();

    this.thompson = this.evaluar(this.postfija);

    this.nfa = Automata.thompsonToNFA(thompson);
    /*  print("NFA");
    this.nfa.printAutomata(); */

    this.dfa = Automata.convertirDFA(this.nfa);
    this.dfaMin = Automata.minimizar(this.dfa);
    //this.dfaMin.printAutomata();
    this.dfaMinSinVacio = Automata.eliminarEstadoVacio(this.dfaMin);
    this.dfaMinSinVacio =
        Automata.renombrarChidoLosEstados(this.dfaMinSinVacio);

    //this.dfaMinSinVacio.printAutomata();
    this.nfa.printAutomata();
  }

  Automata construirBase(String letra) {
    String q0 = Automata.nextState().toString();
    String qf = Automata.nextState().toString();
    List<Transicion> ts = [
      Transicion(qinput: q0, letter: letra, qouput: [qf])
    ];
    Automata resultado = Automata(
      transitions: ts,
      alphabet: [letra],
      states: [q0, qf],
      initialState: q0,
      finalStates: [qf],
    );
    return resultado;
  }

  Automata evaluar(expresion) {
    List<Automata> pila = [];
    for (int i = 0; i < expresion.length; i++) {
      String car = expresion[i];
      if (operadores.indexOf(car) >= 0) {
        // Evaluar
        Automata a = pila.removeLast();
        if (["+", "."].indexOf(car) >= 0) {
          Automata b = pila.removeLast();
          switch (car) {
            case "+":
              b.or(a);
              pila.add(b);
              break;
            case ".":
              b.and(a);
              pila.add(b);
              break;
          }
        }
        if (car == "*") {
          a.kleen();
          pila.add(a);
        }
      } else {
        pila.add(this.construirBase(car));
      }
    }
    return pila.removeLast();
  }

  getPostfix() {
    List<String> opStack = [];
    List<String> postfixList = [];
    String postfix = "";
    for (var i = 0; i < infija.length; i++) {
      String caracter = infija[i];
      if (!operadores.contains(caracter)) {
        postfixList.add(caracter);
        if (!alfabeto.contains(caracter)) {
          alfabeto.add(caracter);
        }
      } else if (caracter == "(") {
        opStack.add(caracter);
      } else if (caracter == ")") {
        String topToken = opStack.removeLast();
        while (topToken != "(") {
          postfixList.add(topToken);
          topToken = opStack.removeLast();
        }
      } else {
        while (opStack.length != 0 &&
            (precedencia[opStack.last] >= precedencia[caracter])) {
          postfixList.add(opStack.removeLast());
        }
        opStack.add(caracter);
      }
    }

    while (opStack.length > 0) {
      postfixList.add(opStack.removeLast());
    }

    postfix = postfixList.join("");

    return postfix;
  }

  bool validarCadena(String cadena) {
    String qActual = this.dfaMinSinVacio.initialState;
    int i = 0;
    while (i < cadena.length) {
      String letraActual = cadena[i];
      if (!this.dfaMinSinVacio.alphabet.contains(letraActual)) return false;
      bool isNext = false;
      for (Transicion t in this.dfaMinSinVacio.transitions) {
        if (letraActual == t.letter && t.qinput == qActual) {
          qActual = t.qouput[0];
          isNext = true;
          break;
        }
      }
      if (!isNext) return false;
      i++;
    }
    return this.dfaMinSinVacio.finalStates.contains(qActual);
  }

  // (a)b => (a).b
  // a*b => a*.b
  // ()() => ().()
  // ab => a.b
  // a() => a.()
  static String formatExpresion(String infija, List<String> operadores) {
    String operador = ".";
    String res = "";
    for (var i = 0; i < infija.length - 1; i++) {
      var c = infija[i];
      var cNext = infija[i + 1];
      if (c == "*" && !operadores.contains(cNext)) {
        res += c + operador;
      } else if (cNext == "(" && !operadores.contains(c)) {
        res += c + operador;
      } else if (cNext == "(" && !operadores.contains(c)) {
        res += c + operador;
      } else if (c == ")" && !operadores.contains(cNext)) {
        res += c + operador;
      } else if (c == ")" && cNext == "(") {
        res += c + operador;
      } else if (!operadores.contains(c) && !operadores.contains(cNext)) {
        res += c + operador;
      } else {
        res += c;
      }
    }
    return res + infija[infija.length - 1];
  }
}
