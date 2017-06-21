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
    this.averageX = 0;
    this.averageY = 0;
    this.averageZ = 0;
    for (int i = 0; i < this.currentCreature.n.size(); i++) {
      Node ni = this.currentCreature.n.get(i);
      this.averageX += ni.x;
      this.averageY += ni.y;
      this.averageZ += ni.z;
    }
    this.averageX = this.averageX/this.currentCreature.n.size();
    this.averageY = this.averageY/this.currentCreature.n.size();
    this.averageZ = this.averageZ/this.currentCreature.n.size();
  }
  
  void setFoodLocation(){
    this.setAverages();
    foodAngle += this.currentCreature.foodPositions[chomps][0];
    float sinA = sin(this.foodAngle);
    float cosA = cos(this.foodAngle);
    float furthestNodeForward = 0;
    for(int i = 0; i < this.currentCreature.n.size(); i++){
      Node ni = this.currentCreature.n.get(i);
      float newX = (ni.x-this.averageX)*cosA-(ni.z-this.averageZ)*sinA;
      if(newX >= furthestNodeForward){
        furthestNodeForward = newX;
      }
    }
    float d = MIN_FOOD_DISTANCE+(MAX_FOOD_DISTANCE-MIN_FOOD_DISTANCE)*this.currentCreature.foodPositions[this.chomps][2];
    
    this.foodX = this.foodX+cos(foodAngle)*(furthestNodeForward+d);
    this.foodZ = this.foodZ+sin(foodAngle)*(furthestNodeForward+d);
    this.foodY = this.currentCreature.foodPositions[chomps][1];
    this.startingFoodDistance = this.getCurrentFoodDistance();
  }

  float getCurrentFoodDistance(){
    float closestDist = 9999;
    for(int i = 0; i < currentCreature.n.size(); i++){
      Node n = this.currentCreature.n.get(i);
      float distFromFood = dist(n.x,n.y,n.z,this.foodX,this.foodY,this.foodZ)-0.4;
      if(distFromFood < closestDist){
        closestDist = distFromFood;
      }
    }
    return closestDist;
  }
  
  float getFitness(){
    Boolean hasNodeOffGround = false;
    for(int i = 0; i < this.currentCreature.n.size(); i++){
      if(this.currentCreature.n.get(i).y <= -0.2001){
        hasNodeOffGround = true;
        break;
      }
    }
    if(hasNodeOffGround){
      float withinChomp = max(1.0-getCurrentFoodDistance()/startingFoodDistance,0);
      return this.chomps+withinChomp;//cumulativeAngularVelocity/(n.size()-2)/pow(averageNodeNausea,0.3);//   /(2*PI)/(n.size()-2); //dist(0,0,averageX,averageZ)*0.2; // Multiply by 0.2 because a meter is 5 units for some weird reason.
    }else{
      return 0;
    }
  }
  
  public Simulation(int cn) {
    this.currentCreature = c[cn].copyCreature(-1,false,true);
    this.creatureNumber = cn;
  }
  
  public void run() {
    this.setFoodLocation();
    for (int i = 0; i < maxIterations; i++) {
      this.currentCreature.simulate(this);
      this.averageNodeNausea = this.totalNodeNausea/currentCreature.n.size();
      this.simulationTimer++;
      this.timer++;
    }
    this.setAverages();
    //if (c[creatureNumber].d != this.getFitness()) {
    //  System.out.print(creatureNumber + ": " + (c[creatureNumber].d - this.getFitness()) + " ;- ");
    //  flush();
    //}
    c[creatureNumber].d = this.getFitness();
  }
}