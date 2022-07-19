#import "Macros.h"
#import "Vector3.hpp"
#import "esp.h"
#import "Obfuscate.h"
#import "Quaternion.hpp"


int get_Health(void *_this){
  return *(int *)((uint64_t)_this + 0xC8);
}

bool get_isLiving(void *_this){
  return get_Health(_this) > 1;
}

bool IsCharacterDead(void *_this){
    return get_Health(_this) < 1;
}


void *(*Component$$get_transform)(void *component) = (void *(*)(void *))getRealOffset(0x26EDDD4);
void (*Transform$$get_position_Injected)(void *Transform, Vector3 *outPosition) = (void (*)(void *, Vector3 *))getRealOffset(0x271E488);


void *camera(){
void *(*get_main)() = (void *(*)())getRealOffset(0x26E7A54);
return (void *) get_main();

}






Vector3 WorldToScreenPoint(void *cam, Vector3 test) {


    Vector3 (*Camera$$WorldToViewport_Injected)(void *, Vector3, int) = (Vector3 (*)(void *,Vector3, int))getRealOffset(0x26E6E48);
    return Camera$$WorldToViewport_Injected(cam, test, 2);
}




Vector3 getPosition(void *component){
  Vector3 out;
  void *transform = Component$$get_transform(component);
  Transform$$get_position_Injected(transform, &out);
  return out;
}



struct enemy_t {
    void *object;
    Vector3 location;
    Vector3 worldtoscreen;
    bool enemy;
    float health;
    
};

struct me_t {
	void *object;
	Vector3 location;
	int team;
};

me_t *me;

class EntityManager {
public:
    std::vector<enemy_t *> *enemies;

    EntityManager() {
        enemies = new std::vector<enemy_t *>();
    }

    bool isEnemyPresent(void *enemyObject) {
        for (std::vector<enemy_t *>::iterator it = enemies->begin(); it != enemies->end(); it++) {
            if ((*it)->object == enemyObject) {
                return true;
            }
        }

        return false;
    }

    void removeEnemy(enemy_t *enemy) {
        for (int i = 0; i < enemies->size(); i++) {
            if ((*enemies)[i] == enemy) {
                enemies->erase(enemies->begin() + i);

                return;
            }
        }
    }
 
    void tryAddEnemy(void *enemyObject) {
        if (isEnemyPresent(enemyObject)) {
            return;
        }

        if (IsCharacterDead(enemyObject)) {
            return;
        }

        enemy_t *newEnemy = new enemy_t();

        newEnemy->object = enemyObject;

        enemies->push_back(newEnemy);
    }

    void updateEnemies(void *enemyObject) {
        for (int i = 0; i < enemies->size(); i++) {
            enemy_t *current = (*enemies)[i];

            if(IsCharacterDead(current->object)) {
                enemies->erase(enemies->begin() + i);
            }
            
        }
    }

    void removeEnemyGivenObject(void *enemyObject) {
        for (int i = 0; i < enemies->size(); i++) {
            if ((*enemies)[i]->object == enemyObject) {
                enemies->erase(enemies->begin() + i);

                return;
            }
        }
    }
    std::vector<enemy_t *> *GetAllEnemies() {
        return enemies;
    }
};



static esp* es;
EntityManager *entityManager = new EntityManager();
int playerTeam = 0;



void (*TickUpdate)(void *_this, float dt);
void _TickUpdate(void *_this, float dt) {
    if(_this != NULL) {
        me->object = _this;
    }
    TickUpdate(_this, dt);
}

void (*Character$$Update)(void* _this, float dt);
void _Character$$Update(void* _this, float dt) 
{

if (_this != NULL) {
  entityManager->tryAddEnemy(_this);
  entityManager->updateEnemies(_this);
  
    std::vector<enemy_t *> *enemies = entityManager->GetAllEnemies();
    std::vector<player_t *> *pplayers = nullptr;
UIWindow *main = [UIApplication sharedApplication].keyWindow;
      void *mycam = camera();
      
      if(me->object != NULL) {
        me->location = getPosition(me->object);
          
            for(int i =0; i<entityManager->enemies->size(); i++){
                
                if(mycam != NULL) {
                  

                  if((*enemies)[i]->object != NULL) {
               (*enemies)[i]->location = getPosition((*enemies)[i]->object);
               if((*enemies)[i]->location != Vector3(0,0,0)) {
              Vector3 orig = (*enemies)[i]->location;
              orig.y += 1.3f;
              (*enemies)[i]->worldtoscreen = WorldToScreenPoint(mycam, orig);
              (*enemies)[i]->enemy = true;
              (*enemies)[i]->health = get_Health((*enemies)[i]->object);
                
            
           
              
                if(!pplayers){
                  pplayers = new std::vector<player_t *>();
                }
                
                  if(!enemies->empty()){
                    for(int i = 0; i < enemies->size(); i++) {
                      if([switches isSwitchOn:@"ESP"]){
                        if((*enemies)[i]->worldtoscreen.z > 0){
                          player_t *newplayer = new player_t();
                          Vector3 newvec = (*enemies)[i]->worldtoscreen;
                          newvec.y = fabsf(1-newvec.y);
                          float dx = 100.0f/(newvec.z/4);
                          float dy = 200.0f/(newvec.z/4);
                          float xxxx = (main.frame.size.width*newvec.x)-dx/2;
                          float yyyy = (main.frame.size.height*newvec.y)-dy/4;

              newplayer->health = (*enemies)[i]->health;
              newplayer->enemy = (*enemies)[i]->enemy;
              newplayer->rect = CGRectMake(xxxx, yyyy, dx, dy);
              newplayer->healthbar = CGRectMake(xxxx, yyyy, 1, dy);
              newplayer->topofbox = CGPointMake(xxxx, yyyy);
            pplayers->push_back(newplayer);
          }
        }
      }
      es.players = pplayers;
    }
        if([switches isSwitchOn:@"ESP BOX"]){
          es.espboxes = true;  
        } else {
          es.espboxes = false;
        }

        if([switches isSwitchOn:@"ESP LINE"]) {
          es.esplines = true;
        } else {
          es.esplines = false;
        }

        if([switches isSwitchOn:@"ESP HEALTHBAR"]) {
          es.healthbarr = true;
        } else {
          es.healthbarr = false;
        }

        
      }
      }
      }
     }
    }
      }
  Character$$Update(_this, dt);
}



void (*Character$$Destroy)(void *_this);
void _Character$$Destroy(void *_this){
if(_this != NULL) {
  entityManager->removeEnemyGivenObject(_this);
  }
Character$$Destroy(_this);
}



void setup(){

me = new me_t();
entityManager= new EntityManager();

HOOK(0x181B934, _TickUpdate, TickUpdate);

HOOK(0x1A5BD28, _Character$$Update, Character$$Update);

HOOK(0x1A5A1B8, _Character$$Destroy, Character$$Destroy);



  [switches addSwitch:@"ESP"
              description:@"ESP"];
			  
  [switches addSwitch:@"ESP BOX"
              description:@"ESP BOX"];


  [switches addSwitch:@"ESP LINE"
              description:@"ESP LINE"];


  [switches addSwitch:@"ESP HEALTHBAR"
              description:@"ESP HEALTHBAR"];

  



}



void setupMenu() {


[menu setFrameworkName:"UnityFramework"];
menu = [[Menu alloc]              
initWithTitle:@"                     Made by Cihan"
watermarkText:@"Made By Cihan"
watermarkTextColor:UIColorFromHex(0xc72c36)
watermarkVisible:1.0
titleColor:[UIColor whiteColor]
titleFont:@"Avenir-Black"
credits:@"Made by cihan#8347"
initWithTitle:@"By cihan#8347"
titleColor:[UIColor whiteColor]
titleFont:@"Avenir-Black"
initWithTitle:@"1.33"
titleColor:[UIColor whiteColor]
titleFont:@"Avenir-Black"
headerColor:[UIColor colorWithRed:0.1 green:0.0 blue:0.0 alpha:0.3]
switchOffColor:[UIColor colorWithRed:0.1 green:0.0 blue:0.0 alpha:0.5]
switchOnColor:UIColorFromHex(0xFF0000)
switchTitleFont:@"AppleSDGothicNeo-Bold"
switchTitleColor:[UIColor whiteColor]
infoButtonColor:[UIColor clearColor]
maxVisibleSwitches:3
menuWidth:340
menuIcon:@""
menuButton:@""];
   
    setup();
}


static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
        UIWindow *main = [UIApplication sharedApplication].keyWindow;
es = [[esp alloc]initWithFrame:main];
        setupMenu();
      }); 



     
    
}


%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}