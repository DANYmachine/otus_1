import 'dart:collection';

class MathExpressionEvaluator {
  final String expression;

  MathExpressionEvaluator({required this.expression});

  double evaluate(Map<String, double> variables) {
    List<String> tokens = tokenize(expression);
    List<String> postfix = infixToPostfix(tokens);
    return evaluatePostfix(postfix, variables);
  }

  List<String> tokenize(String expression) {
    List<String> tokens = [];
    RegExp regExp = RegExp(r"([+\-*/()])|(\d+(\.\d+)?)|([a-zA-Z]+)");

    for (Match match in regExp.allMatches(expression)) {
      tokens.add(match.group(0)!);
    }

    return tokens;
  }

  int getPrecedence(String operator) {
    switch (operator) {
      case "+":
      case "-":
        return 1;
      case "*":
      case "/":
        return 2;
      default:
        return 0;
    }
  }

  List<String> infixToPostfix(List<String> infix) {
    List<String> postfix = [];
    Queue<String> stack = Queue<String>();

    for (String token in infix) {
      if (RegExp(r"\d+(\.\d+)?").hasMatch(token) || RegExp(r"[a-zA-Z]+").hasMatch(token)) {
        postfix.add(token);
      } else if (token == "(") {
        stack.addLast(token);
      } else if (token == ")") {
        while (stack.isNotEmpty && stack.last != "(") {
          postfix.add(stack.removeLast());
        }
        stack.removeLast();
      } else {
        while (stack.isNotEmpty && getPrecedence(stack.last) >= getPrecedence(token)) {
          postfix.add(stack.removeLast());
        }
        stack.addLast(token);
      }
    }

    while (stack.isNotEmpty) {
      postfix.add(stack.removeLast());
    }

    return postfix;
  }

  double evaluatePostfix(List<String> postfix, Map<String, double> variables) {
    Queue<double> stack = Queue<double>();

    for (String token in postfix) {
      if (RegExp(r"\d+(\.\d+)?").hasMatch(token)) {
        stack.addLast(double.parse(token));
      } else if (RegExp(r"[a-zA-Z]+").hasMatch(token)) {
        if (variables.containsKey(token)) {
          stack.addLast(variables[token]!);
        } else {
          throw Exception("Переменная $token не определена.");
        }
      } else {
        double operand2 = stack.removeLast();
        double operand1 = stack.removeLast();
        switch (token) {
          case "+":
            stack.addLast(operand1 + operand2);
            break;
          case "-":
            stack.addLast(operand1 - operand2);
            break;
          case "*":
            stack.addLast(operand1 * operand2);
            break;
          case "/":
            if (operand2 != 0) {
              stack.addLast(operand1 / operand2);
            } else {
              throw Exception("Деление на ноль.");
            }
            break;
        }
      }
    }
    if (stack.length == 1) {
      return stack.first;
    } else {
      throw Exception("Некорректное выражение.");
    }
  }
}

void main() {
  var expression = "2 * (a + b)";
  var evaluator = MathExpressionEvaluator(expression:expression);

  var variables = {"a": 3.0, "b": 5.0};
  try {
    var result = evaluator.evaluate(variables);
    print("Результат выражения: $result");
  } catch (e) {
    print("Ошибка: $e");
  }
}
