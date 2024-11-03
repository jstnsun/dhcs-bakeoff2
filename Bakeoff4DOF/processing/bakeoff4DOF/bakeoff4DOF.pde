import java.util.ArrayList;
import java.util.Collections;

// Square Class to be Inherited From
private class Square {
  float x = displayW/2;
  float y = displayH/2;
  float z = 50f;
  float rotation = 0;
}

// Trial Target
private class Target extends Square {
  boolean isMoving = true;
}

// Trial Destinations
private class Destination extends Square {
}

private class Menu {
  public class Button {
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;
    float startAngle = 0.0f;
    float endAngle = 0.0f;
    
    public Button(int r, int g, int b, int a, float s, float e) {
      this.r = r;
      this.g = g;
      this.b = b;
      this.a = a;
      this.startAngle = s;
      this.endAngle = e;
    }
    
    void drawButton() {
      stroke(0, 0, 0, 0);
      fill(r, g, b, a);
      arc(t.x, t.y, buttonSize, buttonSize, startAngle, endAngle);
    }
    
    boolean isPressed() {
      float start = (startAngle+PI)%TWO_PI;
      float end = (endAngle+PI)%TWO_PI;
      float angle = atan2(mouseY-t.y, mouseX-t.x)+PI;
      if (start <= end) {
        return (angle > start && angle < end);
      } else {
        return (angle > start || angle < end);
      }
    }
  }
  
  Button b0 = new Button(255, 0, 0, 64, -QUARTER_PI, QUARTER_PI);      // Right button, rotates right
  Button b1 = new Button(0, 255, 0, 64, QUARTER_PI, 3*QUARTER_PI);     // Bottom button, decreases size
  Button b2 = new Button(0, 200, 255, 64, 3*QUARTER_PI, 5*QUARTER_PI); // Left button, rotates left
  Button b3 = new Button(255, 255, 0, 64, 5*QUARTER_PI, 7*QUARTER_PI); // Top button, increases size
  float buttonScaleToTarget = 3.0f;
  float buttonSize = t.z * buttonScaleToTarget;
  
  void drawMenu() {
    b0.drawButton();
    b1.drawButton();
    b2.drawButton();
    b3.drawButton();
  }
  
  int pressMenu() {
    if (dist(t.x, t.y, mouseX, mouseY) > buttonSize/2) {
      return -1;
    }
    
    if (b0.isPressed()) {
      t.rotation++;
      return 0;
    } else if (b1.isPressed()) {
      t.z--;
      buttonSize -= buttonScaleToTarget;
      return 1;
    } else if (b2.isPressed()) {
      t.rotation--;
      return 2;
    } else {
      t.z++;
      buttonSize += buttonScaleToTarget;
      return 3;
    }
  }
}

// Program Globals - Leave Alone Unless Specified Otherwise
final int displayW = 1000;   // Size of display width, in pixels
final int displayH = 800;    // Size of display height, in pixels
final int screenPPI = 72;    // PPI of screen being used
float border;                // Border padding from sides of program window
int trialCount = 10;         // Number of trials
int trialIndex = 0;          // Current trial
int errorCount = 0;          // Number of errors made
float errorPenalty = 1.0f;   // Additional penalty time for an error
int startTime = 0;           // Time of first click
int finishTime = 0;          // Time of final click
int lastTime = 0;            // Time of last click
int timeToDoubleClick = 200; // Threshold for a doubleclick
boolean userDone = false;    // Flag for if all trials are over

Target t = new Target();
ArrayList<Destination> destinations = new ArrayList<Destination>();
Menu buttonMenu = new Menu();

void settings() {
  size(displayW, displayH);
}

void setup() {
  textFont(createFont("Arial", inchToPix(.3f)));
  textAlign(CENTER);
  rectMode(CENTER);       // Draw rectangles from the center outwards
  ellipseMode(CENTER);    // Draw ellipses from the center outwards
  border = inchToPix(2f); // Border padding of 2.0"; don't change this
  createDestinations();
}

// Creates a `trialCount` number of destinations
// Don't change this
void createDestinations() {
  println("Creating "+trialCount + " targets");
  for (int i = 0; i < trialCount; i++) {
    Destination d = new Destination();
    d.x = random(border, width-border);             // Set a random x with some padding
    d.y = random(border, height-border);            // Set a random y with some padding
    d.z = (((int)random(20)%12)+1)*inchToPix(.25f); // Sets a random z between .25" and 3.0"
    d.rotation = random(0, 360);                    // Sets a random degre of rotation
    destinations.add(d);
    println("Created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }
  Collections.shuffle(destinations); // Randomizes order of destinations
}

void draw() {
  background(40);
  fill(200);
  noStroke();

  if (userDone) {
    drawDoneScreen();
  } else {
    drawHUD();
    drawDestinations();
    if (!t.isMoving) {
      buttonMenu.drawMenu();
      if (mousePressed) {
        if (buttonMenu.pressMenu() == -1) {
          t.isMoving = true;
        }
      }
    }
    drawTarget();
  }
}

// Draws the screen of program results
// Shouldn't really modify this code unless there is a really good reason to
void drawDoneScreen() {
  text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
  text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
  text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
  text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
}

// Draws text and miscellaneous information on the screen
void drawHUD() {
  fill(255);
  text("Trial " + (trialIndex+1) + " of " + trialCount, width/2, inchToPix(.8f));
}

// Draws the trial destination squares
void drawDestinations() {
  for (int i = trialIndex; i < trialCount; i++) {
    pushMatrix();
    Destination d = destinations.get(i);
    translate(d.x, d.y);         // Center drawing coordinates of destination
    rotate(radians(d.rotation)); // Rotate around origin of destination
    noFill();
    strokeWeight(3f);
    if (trialIndex == i) {
      drawDestinationCenterDot(d.z);
      stroke(255, 0, 0, 192);
    }
    else
      stroke(128, 128, 128, 128);
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
}

// Draws the center dot of a trial destination square
void drawDestinationCenterDot(float len) {
  fill(224, 12, 182, 255);
  circle(0, 0, min(len/4, 16));  
  noFill();
}

// Draws the trial target square
void drawTarget() {
  pushMatrix();
  translate(t.x, t.y);         // Center drawing coordinates of trial
  rotate(radians(t.rotation)); // Rotate around origin of trial
  noStroke();
  if (isCloseEnough()) {
    fill(60, 192, 60, 216);
  } else {
    fill(60, 60, 192, 216);
  }
  rect(0, 0, t.z, t.z);
  popMatrix();
}

void mousePressed() {
  // Start timer on first user click
  if (startTime == 0) {
    startTime = millis();
    lastTime = startTime;
    println("Time started!");
    return;
  }
  
  if (t.isMoving) {
    t.isMoving = false;
  }
  
  if (isDoubleClick() && !userDone) {
    if (!checkForSuccess()) {
      errorCount++;
    }
    trialIndex++;
    if (trialIndex == trialCount) {
      userDone = true;
      finishTime = millis();
    }
    t.isMoving = true;
  }
  lastTime = millis();
}

void mouseMoved() {
  if (t.isMoving) {
    t.x = mouseX;
    t.y = mouseY;
  }
}

// Checks if the current trial was successful
// Probably shouldn't modify this, but email me if you want to for some good reason
public boolean checkForSuccess() {
  Destination d = destinations.get(trialIndex);
  boolean withinD = dist(d.x, d.y, t.x, t.y) < inchToPix(.05f);
  boolean withinR = calculateDifferenceBetweenAngles(d.rotation, t.rotation) <= 5;
  boolean withinZ = abs(d.z - t.z) < inchToPix(.1f);

  println("Close Enough Distance: " + withinD + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + t.x + "/" + t.y +")");
  println("Close Enough Rotation: " + withinR + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, t.rotation)+")");
  println("Close Enough Z: " +  withinZ + " (logo Z = " + d.z + ", destination Z = " + t.z +")");
  println("Close Enough All: " + (withinD && withinR && withinZ));

  return withinD && withinR && withinZ;
}

// Checks if the target matches close enough to the current destination
public boolean isCloseEnough() {
  Destination d = destinations.get(trialIndex);
  boolean withinD = dist(d.x, d.y, t.x, t.y) < inchToPix(.05f);
  boolean withinR = calculateDifferenceBetweenAngles(d.rotation, t.rotation) <= 5;
  boolean withinZ = abs(d.z - t.z) < inchToPix(.1f);
  
  return withinD && withinR && withinZ;
}

// Computes the difference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2) {
  double diff = abs(a1-a2) % 90;
  if (diff > 45)
    return 90-diff;
  else
    return diff;
}

// Converts inches to pixels based on screen's PPI
float inchToPix(float inch) {
  return inch*screenPPI;
}

// Checks if the current click is a doubleclick
boolean isDoubleClick() {
  return millis()-lastTime <= timeToDoubleClick;
}
