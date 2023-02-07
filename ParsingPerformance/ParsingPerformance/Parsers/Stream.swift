//
//  Stream.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation

//extension Parser where Input: RangeReplaceableCollection {
//    var stream: Parser<AnyIterator<Input>, [Output]> {
//        .init { stream in
//            var buffer = Input()
//            var outputs: [Output] = []
//            while let chunk = stream.next() {
//                buffer.append(contentsOf: chunk)
//
//                while let output = self.run(&buffer) {
//                    outputs.append(output)
//                }
//            }
//
//            return outputs
//        }
//    }
//}

var stdin = AnyIterator { readLine(strippingNewline: false)?[...] }

extension Parser where Input: RangeReplaceableCollection {
    func run(
        input: inout AnyIterator<Input>,
        output streamOut: (Output) -> Void
    ) {
        var buffer = Input()
        while let chunk = input.next() {
            buffer.append(contentsOf: chunk)
            
            while let output = self.run(&buffer) {
                streamOut(output)
            }
        }
    }
}

let receipt2 = """
ТОВ "СІЛЬПО-ФУД", магазин
м. Київ, вулиця Дорогожицька, будинок 2  ПН 407201926538  01
00001 Каса островська О./.
H UFK N 31/2155/296
Хл300КиївхлСімейнНар  14,59 Б
29,79 Б
Рул300КиївхлМакв/гВу  КартопляКгБіла  758 Х 7.59  13,34 Б
ЯБлукокгПіноваГолЧер
1,62 Х 20,99  34,00 Б
Сос275ГлобМортадВсВу  57,99 Б
Смет350MiMiMilk201/e  39,99 Б
ПакФасовМайНДГЕ
2 X 0,22  0,44 Б  #
Незабаром здійсниться  #
ваша дитяча мрія.  #
#
B.B. 28349266  #
Бали в моб. додатку  СУМА  190,14 ГРН
ПДВ Б  0,00%  0,00
- .  - -
КАРТКА  190,14 ГРН
...  -- - -  QR2029
ІДЕНТ. ЕКВАЙРА  ТЕРМІНАЛ  QR2029
КОМСІЯ  0,00
ПЛАТІЖНА СИСТЕМА  OR
ВИД ОПЕРАЦІЇ  ОПЛАТА
ЕПЗ  XXXXXX4642  828939
КОД ABT.  RRN  301718978596
КАСИР:
ДЕРЖАТЕЛЬ ЕПЗ:  #
#
Восток  17-01-2023 18:40:18
0633713 0609622  ОН 3000272824
ЗН КС00005950  ABOAAAVUAAAAABUAC69h  AAINWgIMKooXPi/xtpA=
ФІСКАЛЬНИЙ ЧЕК  {Екселліо
"""

//receiptParser.run(
//    input: &stdin,
//    output: { print($0) }
//)
