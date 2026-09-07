import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {


/*------------------------------------------------------------------------------*/
    //variavel para definir o estado

    bool estudando = true;
    bool rodando = false;
    bool iniciou = false;  //se ja foi iniciado

    int minutosEstudo = 25;
    int minutosDescanso = 5;

    int minutosEstudados = 0;
/*-------------------------------------------------------------------*/
  //aqui estamos formatando o tempo usando uma funcao
  //implementando tambem o timer periodc para ele diminuir o tempo

  //variavel (classe) do meu tempo(duração)
  Duration tempoRestante = const Duration(minutes: 25);

  Timer? timer; //variavel de tempo


  //funcao para formatar o tempo em 00:00
  String formatarTempo(Duration tempo) {
    String minutos = tempo.inMinutes.toString().padLeft(2, '0');
    String segundos = (tempo.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutos:$segundos';
  }


  //funcao para o tempo diminuir---------------------------------------------------
  void iniciarTimer() {

    if (rodando) return;
    //verificacao para caso apertar denovo nao danificar o timer

    setState(() {
      rodando = true;
      iniciou = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        //tratamento de tempo ser 0 ou negativo
        if (tempoRestante.inSeconds <= 0) {

          setState(() {

                //se terminou o estudo, adiciona o tempo estudado
              if (estudando) {   //apenas durante o estudo nao o descanso
                minutosEstudados += minutosEstudo;
              }
          
            estudando = !estudando;

            tempoRestante = estudando
                //tempoRestante recebe o tempo de estudo ou descanso
                ? Duration(minutes: minutosEstudo)
                : Duration(minutes: minutosDescanso);
          });

          return;
        }


        setState(() {
          tempoRestante -= const Duration(seconds: 1);
        });
      },
    );
  }


/*-----------------------------------------------------------------------------*/
    //implementar o pausar e continuar

  void pausarTimer() {
    timer?.cancel();        //timer existe?

    setState(() {
      rodando = false;      //trocar a variavel que nao ta rodando
    });
  }


/*-----------------------------------------------------------------------------*/
    //funcao para abrir as configuracoes

  void abrirConfiguracoes() {

    //variaveis temporarias para configurar os tempos
    int novoTempoEstudo = minutosEstudo;
    int novoTempoDescanso = minutosDescanso;

    showDialog(
      context: context,

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return AlertDialog(

              title: const Text('Configurações'),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  //tempo de estudo
                  const Text(
                    'Tempo de estudo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      IconButton(
                        onPressed: () {

                          if (novoTempoEstudo <= 1) return;

                          setStateDialog(() {
                            novoTempoEstudo--;
                          });
                        },

                        icon: const Icon(Icons.remove),
                      ),

                      Text(
                        '$novoTempoEstudo min',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      IconButton(
                        onPressed: () {

                          setStateDialog(() {
                            novoTempoEstudo++;
                          });
                        },

                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),


                  const SizedBox(height: 20),


                  //tempo de descanso
                  const Text(
                    'Tempo de descanso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      IconButton(
                        onPressed: () {

                          if (novoTempoDescanso <= 1) return;

                          setStateDialog(() {
                            novoTempoDescanso--;
                          });
                        },

                        icon: const Icon(Icons.remove),
                      ),

                      Text(
                        '$novoTempoDescanso min',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      IconButton(
                        onPressed: () {

                          setStateDialog(() {
                            novoTempoDescanso++;
                          });
                        },

                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),


              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Cancelar'),
                ),


                ElevatedButton(
                  onPressed: () {

                    setState(() {

                      minutosEstudo = novoTempoEstudo;
                      minutosDescanso = novoTempoDescanso;

                      //se ainda nao iniciou, atualizar o relogio
                      if (!iniciou) {
                        tempoRestante = estudando
                            ? Duration(minutes: minutosEstudo)
                            : Duration(minutes: minutosDescanso);
                      }
                    });

                    Navigator.pop(context);
                  },

                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
/*------------------------------------------------------------*/
    //funcao para formatar o tempo estudado
String formatarTempoEstudado(int minutos) {
  int horas = minutos ~/ 60;
  int minutosRestantes = minutos % 60;

  if (horas > 0) {
    return '${horas}h ${minutosRestantes}min';
  }

  return '$minutosRestantes min';
}


/*-----------------------------------------------------------------------------*/
//funcao para resetar o timer

void resetarTimer() {
  timer?.cancel();        //cancela o timer caso esteja rodando

  setState(() {

    rodando = false;
    iniciou = false;

    //volta para o estado de estudo
    estudando = true;

    //volta o relogio para o tempo de estudo configurado
    tempoRestante = Duration(minutes: minutosEstudo);
  });
}
/*------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Pomodoro'),
      ),


      body: SingleChildScrollView(
  child: Column(
        children: [


    /*--------------------------------------------------------*/
    //conteiner do relogio 

        Align(
        alignment: Alignment.topCenter,

        child: Container(

          //retangulo do timer
          width: 350,
          height: 280,
          padding: const EdgeInsets.all(25),

          decoration: BoxDecoration(
            color: const Color(0xFF15131F),
            borderRadius: BorderRadius.circular(25),
          ),


          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              //estado + botao de configuracao
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    estudando ? 'Estudo' : 'Descanso',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  //botao de configuracao
                  IconButton(
                    onPressed: rodando ? null : abrirConfiguracoes,

                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 20),


              //texto do tempo
              Text(
                formatarTempo(tempoRestante),

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 25),


              //botoes do setstate
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: rodando ? pausarTimer : iniciarTimer,

                    child: Text(
                      rodando
                          ? 'Pausar'
                          : iniciou
                              ? 'Continuar'
                              : 'Iniciar',

                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                ),


                 //botao resetar
                   ElevatedButton(
                     onPressed: resetarTimer,
                
                     child: const Text(
                       'Resetar',
                       style: TextStyle(
                         color: Colors.black,
                       ),
                     ),
                   ),                 
                ],
              ),
            ],
          ),
        ),
      ),

      /*-----------------------------------------------------*/
      //conteiner de instrução
        const SizedBox(height: 20),

    //bloco de instrucoes
    Container(
      width: 350,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color.fromARGB(113, 255, 243, 220),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Como funciona?',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            '- Configure o tempo de estudo e descanso na engrenagem\n'
            '- Inicie o timer. '
            '- Quando o tempo acabar, o Pomodoro trocará automaticamente entre estudo e descanso.'
            '- Apenas um ciclo completo do timer acumulara no tempo estudado'
            "                bons estudos!",
            style: TextStyle(
              color: Color.fromARGB(133, 0, 0, 0),
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),

    /*---------------------------------------------------*/
      //conteiner do acumulador
      const SizedBox(height: 15),

        //container do acumulador
        Container(
         width: 350,
         padding: const EdgeInsets.all(15),
        
         decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 239, 219),
           borderRadius: BorderRadius.circular(15),
         ),
        
         child: Column(
           children: [

              const Text(
               'Tempo estudado',
               style: TextStyle(
                  color: Colors.black,
                 fontSize: 15,
               ),
             ),

             const SizedBox(height: 5),

             Text(
                formatarTempoEstudado(minutosEstudados),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                 fontWeight: FontWeight.bold,
                ),
             ),
           ],
          ),
        ),

        /*--------------------------------------------*/
    ],
   ),
  ),
  );
 }
}