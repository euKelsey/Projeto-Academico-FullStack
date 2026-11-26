import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/screens/meu_cadastro_screen.dart';
import 'package:lava_rapido_app/screens/veiculos_screen.dart';

TextEditingValue formatar(TextInputFormatter formatador, String entrada) {
  return formatador.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: entrada,
      selection: TextSelection.collapsed(offset: entrada.length),
    ),
  );
}

void main() {
  group('Formatador de nome', () {
    final casos = {
      'cliente teste': 'CLIENTE TESTE',
      'João da Silva': 'JOÃO DA SILVA',
      'MARIA': 'MARIA',
      '': '',
    };

    for (final caso in casos.entries) {
      test('deve formatar "${caso.key}"', () {
        expect(formatar(UpperCaseTextFormatter(), caso.key).text, caso.value);
      });
    }

    test('deve preservar posicao do cursor', () {
      final resultado = UpperCaseTextFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'cliente',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );

      expect(resultado.text, 'CLIENTE');
      expect(resultado.selection.baseOffset, 3);
    });
  });

  group('Formatador de telefone', () {
    final casos = {
      '': '',
      '1': '(1',
      '11': '(11) ',
      '119': '(11) 9',
      '113456': '(11) 3456',
      '1134567': '(11) 3456-7',
      '1134567890': '(11) 3456-7890',
      '11912345678': '(11) 91234-5678',
      '11912345678999': '(11) 91234-5678',
      '(11) 91234-5678': '(11) 91234-5678',
      'abc11912345678': '(11) 91234-5678',
      'abc': '',
    };

    for (final caso in casos.entries) {
      test('deve formatar "${caso.key}"', () {
        final resultado = formatar(TelefoneInputFormatter(), caso.key);

        expect(resultado.text, caso.value);

        expect(resultado.selection.baseOffset, caso.value.length);
      });
    }
  });

  group('Formatador de veiculo', () {
    final casos = {
      'Volkswagen': 'VOLKSWAGEN',
      'civic': 'CIVIC',
      'azul metálico': 'AZUL METÁLICO',
      '': '',
    };

    for (final caso in casos.entries) {
      test('deve formatar "${caso.key}"', () {
        final resultado = formatar(VeiculoUpperCaseFormatter(), caso.key);

        expect(resultado.text, caso.value);

        expect(resultado.selection.baseOffset, caso.value.length);
      });
    }
  });

  group('Formatador de placa', () {
    final casos = {
      'abc1234': 'ABC1234',
      'abc1d23': 'ABC1D23',
      'ABC-1234': 'ABC1234',
      'abc 1d23': 'ABC1D23',
      'abc@1#d23': 'ABC1D23',
      'abc123456': 'ABC1234',
      'ABC': 'ABC',
      '': '',
      '!@#': '',
      'abc1d23xyz': 'ABC1D23',
    };

    for (final caso in casos.entries) {
      test('deve formatar "${caso.key}"', () {
        final resultado = formatar(PlacaInputFormatter(), caso.key);

        expect(resultado.text, caso.value);

        expect(resultado.selection.baseOffset, caso.value.length);
      });
    }
  });
}
