final int CS_NORMAL =  0, 
CS_HOVER = 1, 
CS_PRESS = 2, 
CS_CLICK = 3, 
CS_RELEASE = 4;


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
          if (state != CS_PRESS)
          {
            state = CS_PRESS;
            return CS_CLICK;
          }
          return CS_PRESS;
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
  Slider(float init_val, float x_pos, float y_pos, float Width, float Height, color background, color tint)
  {
    //    super.Control(x_pos, y_pos, Width, Height, tint, background);
    state = CS_NORMAL;
    x = x_pos;
    y = y_pos;
    w = Width/1.1;
    h = Height;
    fg = tint;
    bg = background;
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
  }
  int hitTest()
  {
    if (mouseY>=y&&mouseY-y<=h)
    {
      if (mouseX>=x+value*w&&mouseX-(x+value*w)<=w/10&&value>=0&&value<=1)
      {
        // Mouse on block
        if (mousePressed)
        {
          // Update value
          if (state != CS_PRESS)
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
    textSize(h/1.5);
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
    textSize(h/1.5);
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
  if(count<2)
  {return false;}
  if(count>3)
  {return false;}
  if(count==3)
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
Slider spread_ctrl = new Slider(spread, 10,10+cy*w+60,cx*w/2-20, 25, #66ccff,#3366ff);
Slider speed_ctrl = new Slider(0, 5+cx*w/2,10+cy*w+60,cx*w/2-20, 25, #66ccff,#3366ff);

void draw()
{
  background(#ffffff);
  if (mousePressed&&mouseY/w<cy&&mouseY>0&&mouseX>0&&mouseX<cx*w)
  {
    world[mouseX/w][mouseY/w]=true;
  }
  if(running)
  {
    update_world();
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
  }
  reset.draw();
  randomize.draw();
  pause.draw();
  iter.draw();
  spread_ctrl.draw();
}

