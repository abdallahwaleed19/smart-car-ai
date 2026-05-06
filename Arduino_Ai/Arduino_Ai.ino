// =========================================
// SMART CAR FINAL VERSION
// NLP + MQTT + ESP8266 + Arduino + Ultrasonic
// =========================================

// =========================================
// MOTOR DRIVER PINS
// =========================================
#define IN1 9
#define IN2 8
#define IN3 7
#define IN4 6

#define ENA 3
#define ENB 5

// =========================================
// ULTRASONIC PINS
// =========================================
#define TRIG 10
#define ECHO 13

// =========================================
// SETTINGS
// =========================================
#define OBSTACLE_DIST 20

char command = 'S';

// سرعة الحركة الأمامية
int speedForwardLeft  = 210;
int speedForwardRight = 180;

// =========================================
// SETUP
// =========================================
void setup() {

  Serial.begin(9600);

  // Motor pins
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT);

  // Ultrasonic
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  stopMotors();

  Serial.println("SMART CAR READY");
}

// =========================================
// LOOP
// =========================================
void loop() {

  // قراءة الأوامر
  readCommand();

  // قراءة المسافة
  int dist = getDistance();

  // =====================================
  // إرسال المسافة فقط لو اتغيرت
  // =====================================
  static int lastDist = -1;

  if (dist != lastDist) {

    Serial.print("DIST:");
    Serial.println(dist);

    lastDist = dist;
  }

  // =====================================
  // FORWARD
  // =====================================
  if (command == 'F') {

    // لو فيه obstacle
    if (dist < OBSTACLE_DIST) {

      Serial.println("OBSTACLE FRONT");

      stopMotors();
      delay(300);

      // رجوع
      moveBackward();
      delay(500);

      stopMotors();
      delay(300);

      // تحود يمين
      steerRight();
      delay(700);

      stopMotors();
      delay(300);

      return;
    }

    moveForward();
  }

  // =====================================
  // BACKWARD
  // =====================================
  else if (command == 'B') {

    moveBackward();
  }

  // =====================================
  // RIGHT
  // =====================================
  else if (command == 'R') {

    // obstacle أثناء اليمين
    if (dist < OBSTACLE_DIST) {

      Serial.println("RIGHT BLOCKED");

      stopMotors();

      return;
    }

    steerRight();
  }

  // =====================================
  // LEFT
  // =====================================
  else if (command == 'L') {

    // obstacle أثناء الشمال
    if (dist < OBSTACLE_DIST) {

      Serial.println("LEFT BLOCKED");

      stopMotors();

      return;
    }

    steerLeft();
  }

  // =====================================
  // STOP
  // =====================================
  else {

    stopMotors();
  }

  delay(30);
}

// =========================================
// READ COMMAND
// =========================================
void readCommand() {

  if (!Serial.available()) return;

  String msg =
    Serial.readStringUntil('\n');

  msg.trim();

  msg.toUpperCase();

  if (msg == "FORWARD")
    command = 'F';

  else if (msg == "BACKWARD")
    command = 'B';

  else if (msg == "RIGHT")
    command = 'R';

  else if (msg == "LEFT")
    command = 'L';

  else if (msg == "STOP")
    command = 'S';

  Serial.print("CMD:");
  Serial.println(msg);
}

// =========================================
// GET DISTANCE
// =========================================
int getDistance() {

  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIG, LOW);

  long duration =
    pulseIn(ECHO, HIGH, 30000);

  // لو مفيش قراءة
  if (duration == 0)
    return 400;

  int distance =
    duration * 0.034 / 2;

  // فلترة القيم الغلط
  if (distance < 2 || distance > 400)
    return 400;

  return distance;
}

// =========================================
// MOVE FORWARD
// =========================================
void moveForward() {

  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  analogWrite(ENA, speedForwardLeft);
  analogWrite(ENB, speedForwardRight);
}

// =========================================
// MOVE BACKWARD
// =========================================
void moveBackward() {

  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);

  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);

  analogWrite(ENA, 180);
  analogWrite(ENB, 180);
}

// =========================================
// STEER RIGHT
// =========================================
void steerRight() {

  // الاتنين قدام
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  // الشمال أسرع
  analogWrite(ENA, 230);

  // اليمين أبطأ
  analogWrite(ENB, 90);
}

// =========================================
// STEER LEFT
// =========================================
void steerLeft() {

  // الاتنين قدام
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  // اليمين أسرع
  analogWrite(ENA, 90);

  // الشمال أبطأ
  analogWrite(ENB, 230);
}

// =========================================
// STOP MOTORS
// =========================================
void stopMotors() {

  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);

  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);

  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}