//Controls

final int CS_NORMAL =  0, 
CS_HOVER = 1, 
CS_PRESS = 2, 
CS_CLICK = 3, 
CS_RELEASE = 4;

boolean _Control_input_capture =false;

class Control
{
  public float x, y, w, h;
  public color fg, bg;
  int state;
  Control()
  {
  }
  Control(float x_pos, float y_pos, float Width, float Height, color foreground, color background)
  {
    state = CS_NORMAL;
    x = x_pos;
    y = y_pos;
    w = Width;
    h = Height;
    fg = foreground;
    bg = background;
  }
  void draw()
  {
    noStroke();
    fill(bg, 192);
    rect(x, y, w, h);
  }
  int hitTest()
  {
    if (mouseX>=x&&mouseX-x<=w)
    {
      if (mouseY>=y&&mouseY-y<=h)
      {
        // Mouse in area
        if (mousePressed)
        {
          if (state == CS_HOVER)
          {
            // Click
            state = CS_PRESS;
            return CS_CLICK;
          }
          if (state == CS_PRESS)
          {
            // Hold
            return CS_PRESS;
          }
          if (state == CS_NORMAL)
          {
            // Hold and enter
            return CS_NORMAL;
          }
        }
        if (state == CS_PRESS)
        {
          state = CS_HOVER;
          return CS_RELEASE;
        }
        state = CS_HOVER;
        return CS_HOVER;
      }
    }
    state = CS_NORMAL;
    return CS_NORMAL;
  }
}

class Slider extends Control
{
  public float value;
  public String caption;
  public color textcolor;
  Slider(float init_val, String title, float x_pos, float y_pos, float Width, float Height, color blockColor, color textColor, color background)
  {
    caption = title;
    state = CS_NORMAL;
    x = x_pos;
    y = y_pos;
    w = Width/1.1;
    h = Height;
    fg = blockColor;
    bg = background;
    textcolor = textColor;
    value = init_val;
  }
  void draw()
  {
    // Reset Out-of-Bounds
    if (value<0)
    {
      value = 0;
    }
    if (value>1)
    {
      value = 1;
    }
    float w_temp = w; // Slider background must be complete
    w*=1.1;
    super.draw();
    fill(textcolor);
    textAlign(CENTER, CENTER);
    textSize(h/2);
    text(caption, x+w/2, y+h/2);
    w = w_temp; // Set back for slider drawing
    // Draw Slider
    noStroke();
    switch(state)
    {
    case CS_NORMAL:
      fill(fg, 153);
      break;
    case CS_HOVER:
      fill(fg, 255);
      break;
    case CS_PRESS:
      fill(fg, 192);
      break;
    }
    rect(x+value*w, y, w/10, h);
  }
  float drag_begin_displacement; // Temp variable for dragging
  float value0;
  private void updateVal()
  {
    value = value0 + ((float)((mouseX-drag_begin_displacement)))/((float)w);
    if (value<0)
    {
      value = 0;
    }
    if (value>1)
    {
      value = 1;
    }
  }
  int hitTest()
  {
    if (_Control_input_capture&&state!=CS_PRESS)
    {
      return CS_NORMAL;
    }
    // WORK CONTINUES HERE
    if (mouseY>=y&&mouseY-y<=h)
    {
      if (mouseX>=x+value*w&&mouseX-(x+value*w)<=w/10&&value>=0&&value<=1)
      {
        // Mouse on block
        if (mousePressed)
        {
          // Update value
          if (state == CS_NORMAL)
          {
            // Hold mouse and enter
            return CS_NORMAL;
          }
          if (state == CS_HOVER)
          {
            // Just Began dragging
            drag_begin_displacement = mouseX;
            value0 = value;
          }
          updateVal();
          state = CS_PRESS;
          return CS_PRESS;
        }
        state = CS_HOVER;
        return CS_HOVER;
      }
      // Outside, fall out
    }
    if (mousePressed&&state==CS_PRESS&&value>=0&&value<=1)
    {
      // Drag out of region, but continue
      updateVal();
      return CS_PRESS;
    }
    state = CS_NORMAL;
    return CS_NORMAL;
  }
}

class Button extends Control
{
  public String caption;
  Button()
  {
  }
  Button(String Title, float x_pos, float y_pos, float Width, float Height, color textColor, color background)
  {
    caption = Title;
    x = x_pos;
    y = y_pos;
    w = Width;
    h = Height;
    fg = textColor;
    bg = background;
  }
  void draw()
  {
    noStroke();
    switch(state)
    {
    case CS_NORMAL:
      fill(bg, 153);
      break;
    case CS_HOVER:
      fill(bg, 255);
      break;
    case CS_PRESS:
      fill(bg, 192);
      break;
    }
    rect(x, y, w, h);
    fill(fg);
    textSize(h/2);
    textAlign(CENTER, CENTER);
    text(caption, x+w/2, y+h/2);
    // This line has an unknown problem with processing.js
    // the text(String, int, int, int, int) will never draw
    // So I have to do it in another way
  }
}

class StateButton extends Button
{
  public boolean selected;
  StateButton(boolean Selected, String Title, float x_pos, float y_pos, float Width, float Height, color textColor, color background)
  {
    selected = Selected;
    caption = Title;
    x = x_pos;
    y = y_pos;
    w = Width;
    h = Height;
    fg = textColor;
    bg = background;
  }
  void draw()
  {
    noStroke();
    switch(state)
    {
    case CS_NORMAL:
      if (selected)
      {
        fill(bg, 255);
      } else
      {
        fill(bg, 153);
      }
      break;
    case CS_HOVER:
      fill(bg, 255);
      break;
    case CS_PRESS:
      fill(bg, 192);
      break;
    }
    rect(x, y, w, h);
    fill(fg);
    textSize(h/2);
    textAlign(CENTER, CENTER);
    text(caption, x+w/2, y+h/2);
  }
  int hitTest()
  {
    int test_result = super.hitTest();
    if (test_result == CS_CLICK)
    {
      selected = true;
    }
    return test_result;
  }
}

class Switch extends Button
{
  public boolean value;
  Switch(boolean initVal, String Title, float x_pos, float y_pos, float Width, float Height, color textColor, color background)
  {
    value = initVal;
    caption = Title;
    x = x_pos;
    y = y_pos;
    w = Width;
    h = Height;
    fg = textColor;
    bg = background;
  }  
  int hitTest()
  {
    int result = super.hitTest();
    if (result == CS_CLICK)
    {
      value = !value;
    }
    return result;
  }
  void draw()
  {
    super.draw();
    stroke(#FFFFFF);
    if (value)
    {
      fill(#00ff00, 255);
    } else
    {
      fill(#666666, 153);
    }
    ellipse(x+8, y+h/2, h/2, h/2);
  }
}

// begin

int cx = 100, 
cy = 100, 
w = 5;
float spread=0.38;
color alive_color=#66ccff;

boolean[][] world = new boolean[cx][cy];
boolean running = true;
int skip=0;
int lone = 2, crowd = 3, reproduce = 3;

void setup()
{
  size(cx*w, cy*w+150);
}

void render_world()
{
  fill(alive_color);
  for (int i=0; i!=cx; i++)
  {
    for (int j=0; j!=cy; j++)
    {
      if (world[i][j])
      {
        rect(i*w, j*w, w, w);
      }
    }
  }
}

boolean retrive_state(int x, int y)
{
  // Retrive matrix cell value with overflow/underflow detection
  if (x<0||x>=cx||y<0||y>=cy)
  {
    return false;
  }
  if (world[x][y])
  {
    return true;
  } else
  {
    return false;
  }
}

int neighbor_count(int x, int y)
{
  int count=0;
  if(retrive_state(x-1,y-1))
  {count++;}
  if(retrive_state(x,y-1))
  {count++;}
  if(retrive_state(x+1,y-1))
  {count++;}
  if(retrive_state(x-1,y))
  {count++;}
  if(retrive_state(x+1,y))
  {count++;}
  if(retrive_state(x-1,y+1))
  {count++;}
  if(retrive_state(x,y+1))
  {count++;}
  if(retrive_state(x+1,y+1))
  {count++;}
  return count;
}

boolean update_cell(int x, int y)
{
  int count = neighbor_count(x,y);
  if(count<lone)
  {return false;}
  if(count>crowd)
  {return false;}
  if(count==reproduce)
  {return true;}
  return world[x][y];
}

void update_world()
{
  boolean[][] new_world = new boolean[cx][cy];
  for (int i=0; i!=cx; i++)
  {
    for (int j=0; j!=cy; j++)
    {
      new_world[i][j]=update_cell(i, j);
    }
  }
  world = new_world;
}

Button reset = new Button("Clear", 10, 10+cy*w, cx*w/2-20, 25, #000000,#66ccff);
Button randomize = new Button("Randomize", 5+cx*w/2, 10+cy*w, cx*w/2-20, 25, #000000,#66ccff);
Button pause = new Button("Pause", 10, 10+cy*w+30, cx*w/2-20, 25, #000000,#66ccff);
Button iter = new Button("Iterate", 5+cx*w/2, 10+cy*w+30, cx*w/2-20, 25, #000000,#66ccff);

Slider spread_ctrl = new Slider(spread, "Spread:"+spread*100+"%", 10,10+cy*w+60,cx*w/2-20, 25,#3366ff, #000000,#66ccff);
Slider speed_ctrl = new Slider(1,"Speed:100%", 5+cx*w/2,10+cy*w+60,cx*w/2-20, 25, #3366ff, #000000,#66ccff);

Slider lone_ctrl = new Slider(0.2,"Lone:"+lone, 10,10+cy*w+90,cx*w/3-20, 25, #3366ff, #000000,#66ccff);
Slider crowd_ctrl = new Slider(0.3,"Crowd:"+crowd, 5+cx*w/3,10+cy*w+90,cx*w/3-20, 25,  #3366ff,#000000,#66ccff);
Slider reproduce_ctrl = new Slider(0.3,"Reproduce:"+reproduce, 5+cx*w/3*2,10+cy*w+90,cx*w/3-20, 25,  #3366ff,#000000,#66ccff);


int current_skip = 0;

void draw()
{
  background(#ffffff);
  if (mousePressed&&mouseY<cy*w&&mouseY>0&&mouseX>0&&mouseX<cx*w)
  {
    world[(int)(mouseX/w)][(int)(mouseY/w)]=true;
  }
  render_world();

  if(reset.hitTest()==CS_CLICK)
  {
    setup();
    for(int i=0; i!=cx; i++)
    {
      for(int j=0; j!=cy; j++)
      {
          world[i][j]=false;
      }
    }
  }
  if(randomize.hitTest()==CS_CLICK)
  {
    setup();
    for(int i=0; i!=cx; i++)
    {
      for(int j=0; j!=cy; j++)
      {
        if(random(0,1)<spread)
        {
          world[i][j]=true;
        }else
		{
		  world[i][j]=false;
		}
      }
    }
  }
  if(pause.hitTest()==CS_CLICK)
  {
    running = !running;
  }
  if(iter.hitTest()==CS_CLICK)
  {
    update_world();
  }
  if(spread_ctrl.hitTest()==CS_PRESS)
  {
    spread = spread_ctrl.value;
    spread_ctrl.caption = "Spread:"+spread*100+"%";
  }
  if(speed_ctrl.hitTest()==CS_PRESS)
  {
    skip = (int)((1-speed_ctrl.value)*10);
    speed_ctrl.caption = "Speed:"+speed_ctrl.value*100+"%";
  }
  if(lone_ctrl.hitTest()==CS_PRESS)
  {
    lone = (int)((lone_ctrl.value)*10);
    lone_ctrl.caption = "Lone:"+lone;
  }
  if(crowd_ctrl.hitTest()==CS_PRESS)
  {
    crowd = (int)((crowd_ctrl.value)*10);
    crowd_ctrl.caption = "Crowd:"+crowd;
  }
  if(reproduce_ctrl.hitTest()==CS_PRESS)
  {
    reproduce = (int)((reproduce_ctrl.value)*10);
    reproduce_ctrl.caption = "Reproduce:"+reproduce;
  }
  reset.draw();
  randomize.draw();
  pause.draw();
  iter.draw();
  spread_ctrl.draw();
  speed_ctrl.draw();
  lone_ctrl.draw();
  crowd_ctrl.draw();
  reproduce_ctrl.draw();
  
  // Speed control
  if(current_skip<skip)
  {
    current_skip++;
    return;
  }
  current_skip = 0; // reset;
  
  // auto update below
  if(running)
  {
    update_world();
  }


}

