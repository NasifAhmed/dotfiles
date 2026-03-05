public class ProgrammingClass5 {
  public static void main(String[] args) {
    
//    int limitY = 1;
//    int limitX = 1;
//    
//    while(limitY <= 10) {
//      while(limitX <= 10) {
//        System.out.print(limitX);
//        limitX = limitX + 1;
//      }
//      limitY = limitY + 1;
//      limitX = 1;
//      System.out.println();
//    }
//    
    
    for(int limitY=1 ; limitY<=10 ; limitY = limitY + 1) {
      for(int limitX=1 ; limitX<=10 ; limitX = limitX + 1) {
        System.out.print(limitX);
      }
      System.out.println();
    }
  }
}