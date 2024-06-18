class Automata {
  List<String> states = [];
  List<String> alphabet = [];
  List<String> finalStates = [];
  String initialState = '';
  late Automata nfa;
  late Automata thompson;
  late Automata afd;
  late Automata afdreducido;

  //Constructor
  Automata({
    required this.states,
    required this.alphabet,
    required this.finalStates,
    required this.initialState,
    required this.transitions,
  });

  static int contadorAutomatas = 0;
  static int nextState() {
    contadorAutomatas++;
    return contadorAutomatas;
  }

  bool validarCadena(String cadena, Automata a) {
    String qActual = a.initialState;
    int i = 0;
    while (i < cadena.length) {
      String letraActual = cadena[i];
      if (!a.alphabet.contains(letraActual)) return false;
      bool isNext = false;
      for (Transicion t in a.transitions) {
        if (letraActual == t.letter && t.qinput == qActual) {
          qActual = t.qouput[0];
          isNext = true;
          break;
        }
      }
      if (!isNext) return false;
      i++;
    }
    return a.finalStates.contains(qActual);
  }

  List<Transicion> transitions = [];

  static Automata convertirDFA(Automata a) {
    List<List<String>> nuevosEstados = [
      [a.initialState]
    ];

    List<String> nuevosEstadosAux = [
      [a.initialState].toString()
    ];
    List<List<String>> finales = [];
    if (a.finalStates.contains(a.initialState)) {
      finales.add([a.initialState]);
    }
    List<String> finalesAux = [];
    String inicial = [a.initialState].toString();
    List<Transicion> nuevasTransiciones = [];

    int i = 0;
    while (i < nuevosEstados.length) {
      List<String> q = nuevosEstados[i];
      print(nuevosEstados);
      for (String letra in a.alphabet) {
        List<String> qOutput = a.busqueda(q, letra);
        qOutput.sort();
        if (!nuevosEstadosAux.contains(qOutput.toString())) {
          nuevosEstados.add(qOutput);
          nuevosEstadosAux.add(qOutput.toString());
        }
        for (var j = 0; j < qOutput.length; j++) {
          if (!finalesAux.contains(qOutput.toString()) &&
              a.finalStates.contains(qOutput[j])) {
            finales.add(qOutput);
            break;
          }
        }
        Transicion t =
            Transicion(qinput: q.toString(), letter: letra, qouput: qOutput);

        nuevasTransiciones.add(t);
      }
      i++;
    }

    return Automata(
        states: nuevosEstados.map((f) => f.toString()).toList(),
        finalStates: finales.map((f) => f.toString()).toList(),
        alphabet: a.alphabet,
        initialState: inicial,
        transitions: nuevasTransiciones);

    /*  a.afdreducido = a.afd.renombrar(a.afd);
    a.afdreducido.printAutomata();
    a.afdreducido.eliminarEstadosRepetidos();
    afdreducido.printAutomata();
    return afdreducido; */
  }

  static Automata eliminarEstadoVacio(Automata a) {
    for (String q in a.states) {
      if (!a.finalStates.contains(q)) {
        int coincidencias = 0;
        for (String letra in a.alphabet) {
          Transicion? t = a.getTrasiciones(q, letra);
          if (t != null && t.qouput.length == 1 && t.qouput[0] == q) {
            coincidencias++;
          }
        }
        //Eliminar el estado vacio
        if (coincidencias == a.alphabet.length) {
          print("$q es el estado vacio!!! tenemos que eliminarl :O");
          a.states.remove(q);
          for (var i = 0; i < a.transitions.length; i++) {
            Transicion taux = a.transitions[i];
            if (taux.qinput == q) {
              a.transitions.removeAt(i);
              i--;
            } else if (taux.qouput.length == 1 && taux.qouput[0] == q) {
              a.transitions.removeAt(i);
              i--;
            }
          }

          return a;
        }
      }
    }
    return a;
  }

  static Automata renombrarChidoLosEstados(Automata a) {
    List<String> qs = [];
    List<String> qFinales = [];
    for (int i = 0; i < a.states.length; i++) {
      String q = a.states[i];
      qs.add('q$i');
      if (a.finalStates.contains(q)) {
        qFinales.add('q$i');
      }
    }

    List<Transicion> ts = [];
    for (Transicion t in a.transitions) {
      List<String> qOutput = [];
      for (String qO in t.qouput) {
        qOutput.add("q" + a.states.indexOf(qO).toString());
      }
      ts.add(Transicion(
          qinput: "q" + a.states.indexOf(t.qinput).toString(),
          letter: t.letter,
          qouput: qOutput));
    }
    return Automata(
        initialState: 'q0',
        alphabet: a.alphabet,
        finalStates: qFinales,
        states: qs,
        transitions: ts);
  }

  eliminarEstadosRepetidos() {
    //Empezar a checar todas las transiciones
    int i = 0;
    while (i < states.length - 1) {
      String qActual = states[i];
      for (var j = i + 1; j < states.length; j++) {
        String qComparar = states[j];
        if (finalStates.contains(qActual) && finalStates.contains(qComparar) ||
            !finalStates.contains(qActual) &&
                !finalStates.contains(qComparar)) {
          int numeroCoincidencias = 0;
          for (String letra in alphabet) {
            Transicion? tQActual = getTrasiciones(qActual, letra);
            Transicion? tQComparar = getTrasiciones(qComparar, letra);

            if (tQActual != null && tQComparar != null) {
              if (tQActual.qouput.toString() == tQComparar.qouput.toString()) {
                numeroCoincidencias++;
              }
            }
          }

          if (numeroCoincidencias == alphabet.length) {
            //Si se cumple esta condición se tiene que eliminar y renombrar el estado repetido
            //print("$qActual y $qComparar son iguales");
            states.remove(qComparar);
            finalStates.remove(qComparar);
            //Eliminar las transiciones de ese estado

            for (var i = 0; i < transitions.length; i++) {
              Transicion t = transitions[i];
              //print("Esta t= $t");
              //print("${t.qinput} == $qComparar");
              if (t.qinput == qComparar) {
                //print("Tenemos que eliminarla");
                transitions.removeAt(i);
                i--;
              } else if (t.qouput.contains(qComparar)) {
                int index = t.qouput.indexOf(qComparar);
                //print("Quitando ${t.qouput}");
                while (index != -1) {
                  t.qouput[index] = qActual;
                  index = t.qouput.indexOf(qComparar);
                }
                //print("Quedó así ${t.qouput}");
              }
            }
            i = -1;
          }
        }
      }
      i++;
    }
  }

  Transicion? getTrasiciones(String q, String letra) {
    for (Transicion t in transitions) {
      if (t.qinput == q && t.letter == letra) {
        return t;
      }
    }
    return null;
  }

  void printAutomata() {
    print("Q = $states");
    print("QF = $finalStates");
    print("QS = $initialState");
    print("A = $alphabet");
    for (var t in transitions) {
      print(t.toString());
    }
  }

  //Clausura Epsilon
  List<String> epsilonClosure(String q, List<Transicion> ts) {
    List<String> qs = [];
    qs.add(q);
    List<String> busqueda = [];
    List<String> busquedaHistorial = [];
    busqueda.add(q);
    busquedaHistorial.add(q);
    //print("Estado $q");
    //print("TS: $ts");

    while (busqueda.length > 0) {
      String qBuscando = busqueda[0];

      for (Transicion t in ts) {
        if (t.qinput == qBuscando &&
            t.letter == "" &&
            qs.indexOf(t.qouput.toString()) == -1) {
          if (!busquedaHistorial.contains(t.qouput.toString())) {
            qs.addAll(t.qouput);
            busqueda.addAll(t.qouput);
            busquedaHistorial.add(t.qouput.toString());
          }
        }
      }
      busqueda.removeAt(0);
    }

    qs.sort();
    //print("Resultado $qs");
    return qs;
  }

  static Automata thompsonToNFA(Automata thompson) {
    List<String> ep1 = [];
    Map<String, int> mapEstados = new Map();
    List<String> finales = [];
    List<Transicion> ts = [];
    for (String q in thompson.states) {
      ep1 = thompson.epsilonClosure(q, thompson.transitions);
      if (finales.indexOf(thompson.finalStates[0]) == -1 &&
          ep1.contains(thompson.finalStates[0])) {
        finales.add(q);
      }
      for (String letra in thompson.alphabet) {
        List<String> alcanzables =
            thompson.alcanzables(ep1, thompson.transitions, letra);
        //print("Alcanzables $alcanzables");
        List<String> ep2 = [];
        for (String q in alcanzables) {
          List<String> epCs = thompson.epsilonClosure(q, thompson.transitions);
          print(epCs);
          for (var q2 in epCs) {
            if (ep2.indexOf(q2) == -1) ep2.add(q2);
          }
        }
        if (mapEstados[ep2.toString()] == null)
          mapEstados[ep2.toString()] = Automata.nextState();

        if (ep2.length > 0) {
          //print("($q,$letra) = ${ep2.toString()}");
          ts.add(Transicion(
            qinput: q,
            letter: letra,
            qouput: ep2,
          ));
        }
      }
    }

    return new Automata(
        states: thompson.states,
        alphabet: thompson.alphabet,
        finalStates: finales,
        initialState: thompson.initialState,
        transitions: ts);
  }

  //Alcanzables con una letra
  List<String> alcanzables(
      List<String> lista, List<Transicion> ts, String letra) {
    List<String> qs = [];
    /*  print("lista $lista");
    print("letra $letra"); */
    for (String q in lista) {
      for (Transicion t in ts) {
        //print(t);
        if (t.qinput == q && t.letter == letra) {
          qs.addAll(t.qouput);
        }
      }
    }
    qs.sort();
    return qs;
  }

  @override
  String toString() {
    String ts = "( ";
    for (var t in transitions) {
      ts = ts + t.toString() + ", ";
    }
    ts = ts + " )";
    return "Q = $states"
        "QF = $finalStates"
        "QS = $initialState"
        "A = $alphabet"
        "TS =>  $ts";
  }

  static minimizar(Automata a) {
    Automata aMinimizado = Automata.renombrar(a);
    aMinimizado.eliminarEstadosRepetidos();
    return aMinimizado;
  }

  static Automata renombrar(Automata a) {
    //Renombrar estados

    //Buscar transiciones del estado inicial
    String estadoActual = a.initialState;
    List<String> porRecorrer = [estadoActual];
    List<String> estados = [estadoActual];
    int i = 0;
    List<Transicion> tsRenombradas = [];
    while (i < porRecorrer.length) {
      String q = porRecorrer[i];

      List<Transicion> ts = a.buscarTransiciones(q, a.transitions);

      List<List<String>> siguientes = ts.map((f) => f.qouput).toList();

      for (List<String> s in siguientes) {
        if (estados.indexOf(s.toString()) == -1) {
          estados.add(s.toString());
        }
        if (porRecorrer.indexOf(s.toString()) == -1) {
          porRecorrer.add(s.toString());
        }
      }
      for (Transicion t in ts) {
        Transicion newT = Transicion(
            qinput: "q${estados.indexOf(t.qinput)}",
            letter: t.letter,
            qouput: ["q${estados.indexOf(t.qouput.toString())}"]);
        tsRenombradas.add(newT);
      }

      i++;
    }
    List<String> estadosRenombrados = [];
    List<String> finalesRenombrados = [];
    for (var i = 0; i < estados.length; i++) {
      estadosRenombrados.add('q$i');
      if (a.finalStates.contains(estados[i])) {
        finalesRenombrados.add('q$i');
      }
    }

    Automata resultado = new Automata(
        transitions: tsRenombradas,
        states: estadosRenombrados,
        finalStates: finalesRenombrados,
        alphabet: a.alphabet,
        initialState: 'q0');
    return resultado;
  }

  //Busca las transiciones de un estado
  List<Transicion> buscarTransiciones(String q, List<Transicion> ts) {
    List<Transicion> resultado = [];
    for (Transicion t in ts) {
      if (t.qinput == q) {
        resultado.add(t);
      }
    }
    return resultado;
  }

  List<String> busqueda(List<String> estados, String letter) {
    List<String> resultado = [];
    for (String q in estados) {
      for (Transicion t in transitions) {
        if (t.qinput == q && t.letter == letter) {
          resultado.addAll(t.qouput);
        }
      }
    }

    if (resultado.length > 0) {
      resultado = resultado.toSet().toList();
      resultado.sort();
    }
    return resultado;
  }

  static formatBin(int size, int bin) {
    String binString = bin.toString();
    while (binString.length < size) {
      binString = '0' + binString;
    }

    return binString;
  }

  static int toBin(int decimal) {
    int bin = 0, i = 1;
    while (decimal > 0) {
      bin = bin + (decimal % 2) * i;
      decimal = (decimal / 2).floor();
      i = i * 10;
    }
    return bin;
  }

  //RE
  void or(Automata a) {
    String e0 = Automata.nextState().toString();
    String e01 = initialState;
    String e02 = a.initialState;
    List<String> ef1 = finalStates;
    List<String> ef2 = a.finalStates;
    String ef0 = Automata.nextState().toString();

    states.add(e0);
    states.add(ef0);
    joinElementos(a);

    transitions.add(Transicion(qinput: e0, letter: "", qouput: [e01]));
    transitions.add(Transicion(qinput: e0, letter: "", qouput: [e02]));
    transitions.add(Transicion(qinput: ef1[0], letter: "", qouput: [ef0]));
    transitions.add(Transicion(qinput: ef2[0], letter: "", qouput: [ef0]));
    initialState = e0;
    finalStates = [ef0];
  }

  void and(Automata a) {
    String e01 = initialState;
    String e02 = a.initialState;
    List<String> ef1 = finalStates;
    List<String> ef2 = a.finalStates;

    transitions.add(Transicion(qinput: ef1[0], letter: "", qouput: [e02]));
    joinElementos(a);
    finalStates = ef2;
    initialState = e01;
  }

  void kleen() {
    String e01 = initialState;
    List<String> ef1 = finalStates;
    String e0 = Automata.nextState().toString();
    String ef0 = Automata.nextState().toString();

    states.add(e0);
    states.add(ef0);

    transitions.add(Transicion(qinput: e0, letter: "", qouput: [e01]));
    transitions.add(Transicion(qinput: e0, letter: "", qouput: [ef0]));
    transitions.add(Transicion(qinput: ef1[0], letter: "", qouput: [e01]));
    transitions.add(Transicion(qinput: ef1[0], letter: "", qouput: [ef0]));

    finalStates = [ef0];
    initialState = e0;
  }

  joinEstados(Automata a) {
    for (String e in a.states) {
      if (states.indexOf(e) == -1) {
        states.add(e);
      }
    }
  }

  joinAlfabeto(Automata a) {
    for (String c in a.alphabet) {
      if (alphabet.indexOf(c) == -1) {
        alphabet.add(c);
      }
    }
    alphabet.sort();
  }

  joinTransiciones(Automata a) {
    for (Transicion t in a.transitions) {
      if (transitions.indexOf(t) == -1) {
        transitions.add(t);
      }
    }
  }

  joinElementos(Automata a) {
    joinTransiciones(a);
    joinAlfabeto(a);
    joinEstados(a);
  }
}

class Transicion {
  String qinput = "";
  List<String> qouput = [];
  String letter = "";

  Transicion({qinput, letter, qouput});

  @override
  String toString() {
    return "($qinput, $letter) = $qouput";
  }
}
