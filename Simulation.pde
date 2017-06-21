//everything in this is new
//new

class Simulator extends Thread {
  int start;
  int end;
  
  public Simulator(int _start, int _end) {
    this.start = _start;
    this.end = _end;
  }
  
  public void run() {
    for (int i = start; i < end; i++) {
      new Simulation(i).run();
    }
  }
}


class Simulation {
  Creature currentCreature;
  int maxIterations = 900;
  int creatureNumber;
  int timer = 0;
  int simulationTimer = 0;
  float energy = baselineEnergy;
  float totalNodeNausea = 0;
  float averageNodeNausea = 0;
  float cumulativeAngularVelocity = 0;
  float foodX = 0;
  float foodY = 0;
  float foodZ = 0;
  float foodAngle = 0;
  int chomps = 0;
  float averageX;
  float averageY;
  float averageZ;
  float startingFoodDistance = 0;
  
  void setAverages() {
    averageX = 0;
    averageY = 0;
    averageZ = 0;
    for (int i = 0; i < currentCreature.n.size(); i++) {
      Node ni = currentCreature.n.get(i);
      averageX += ni.x;
      averageY += ni.y;
      averageZ += ni.z;
    }
    averageX = averageX/currentCreature.n.size();
    averageY = averageY/currentCreature.n.size();
    averageZ = averageZ/currentCreature.n.size();
  }
  
  void setFoodLocation(){
    setAverages();
    foodAngle += currentCreature.foodPositions[chomps][0];
    float sinA = sin(foodAngle);
    float cosA = cos(foodAngle);
    float furthestNodeForward = 0;
    for(int i = 0; i < currentCreature.n.size(); i++){
      Node ni = currentCreature.n.get(i);
      float newX = (ni.x-averageX)*cosA-(ni.z-averageZ)*sinA;
      if(newX >= furthestNodeForward){
        furthestNodeForward = newX;
      }
    }
    float d = MIN_FOOD_DISTANCE+(MAX_FOOD_DISTANCE-MIN_FOOD_DISTANCE)*currentCreature.foodPositions[chomps][2];
    foodX = foodX+cos(foodAngle)*(furthestNodeForward+d);
    foodZ = foodZ+sin(foodAngle)*(furthestNodeForward+d);
    foodY = currentCreature.foodPositions[chomps][1];
    startingFoodDistance = getCurrentFoodDistance();
  }

  float getCurrentFoodDistance(){
    float closestDist = 9999;
    for(int i = 0; i < currentCreature.n.size(); i++){
      Node n = currentCreature.n.get(i);
      float distFromFood = dist(n.x,n.y,n.z,foodX,foodY,foodZ)-0.4;
      if(distFromFood < closestDist){
        closestDist = distFromFood;
      }
    }
    return closestDist;
  }
  
  float getFitness(){
    Boolean hasNodeOffGround = false;
    for(int i = 0; i < currentCreature.n.size(); i++){
      if(currentCreature.n.get(i).y <= -0.2001){
        hasNodeOffGround = true;
        break;
      }
    }
    if(hasNodeOffGround){
      float withinChomp = max(1.0-getCurrentFoodDistance()/startingFoodDistance,0);
      return chomps+withinChomp;//cumulativeAngularVelocity/(n.size()-2)/pow(averageNodeNausea,0.3);//   /(2*PI)/(n.size()-2); //dist(0,0,averageX,averageZ)*0.2; // Multiply by 0.2 because a meter is 5 units for some weird reason.
    }else{
      return 0;
    }
  }
  
  public Simulation(int cn) {
    currentCreature = c[cn].copyCreature(-1,false,true);
    creatureNumber = cn;
  }
  
  public void run() {
    setFoodLocation();
    for (int i = 0; i < maxIterations; i++) {
      currentCreature.simulate(this);
      averageNodeNausea = totalNodeNausea/currentCreature.n.size();
      simulationTimer++;
      timer++;
    }
    this.setAverages();
    c[creatureNumber].d = this.getFitness();
  }
}