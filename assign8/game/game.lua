local ROT = require 'deps/rotLove/rot'
local termfx = require "termfx"
local class = require "class.class"
local types = require "class.types"
local Point = require "point.point"
local tiles = require "game.tiles"
local Hero = require "game.hero"
local Monster = require "game.monster"
local Light = require "game.light"
local Entity = require "game.entity"

local FG
local BG

local MAP_SIZE = Point:new(70, 30)
local LOG_SIZE = Point:new(40, 29)
local NUM_MONSTERS = 3

local Game = class.class({class.Object}, function(Class)
    function Class:constructor()
      self.loglines = {}
      self.tiles = {}
      self.floors = {}
      self.input = ""
      self.lights_on = false
      self.entities = {}

      self:log("Welcome to a Lua roguelike.")
      self:log("Use arrow keys to move. Move into an enemy to attack. Use (tab) to wait. ")
      self:log("Press (q) to quit.")

      -- Construct map.
      local brogue = ROT.Map.Rogue(MAP_SIZE:x(), MAP_SIZE:y())
      brogue:create(
        function(x, y, val)
          local tile = ({tiles.GroundTile, tiles.WallTile, tiles.DoorTile})[val+1]
          if self.tiles[x] == nil then self.tiles[x] = {} end
          self.tiles[x][y] = tile:new()
          if tiles.GroundTile:is(self.tiles[x][y]) then
            table.insert(self.floors, Point:new(x,y))
          end
        end, false)

      -- Place hero, lights, and monsters.
      self._hero = Hero:new(self, self:random_floor())
      self.lights = {Light:new(self, self._hero:pos(), 0.5)}
      for _ = 1, NUM_MONSTERS do
        Monster:new(self, self:random_floor())
      end
    end

    function Class:start()
      termfx.init()
      termfx.outputmode(termfx.output.COL256)
      FG = termfx.grey2color(23)
      BG = termfx.grey2color(2)
      termfx.attributes(FG, BG)
      local _, err = pcall(function()
          self:draw()
          while true do
            local evt = termfx.pollevent()
            if evt.char == "q" then
              break
            else
              self:handle_input(evt)
            end
            self:draw()
          end
      end)
      termfx.shutdown()

      if err ~= nil then
        print(err)
        print(debug.traceback())
      end
    end

    -- Tries to move the entity by a relative vector. If the movement would
    -- put the entity in a wall, then no movement occurs. If the movement would
    -- put the entity in another enitity, the movement is cancelled and the
    -- collide function is called. Generally, this translates to an attack.
    function Class:try_move(entity, vector)
      if vector:x() == 0 and vector:y() == 0 then return end

      local pos = entity:pos()
      local dst = pos + vector

      -- Collision detection with walls
      if tiles.WallTile:is(self.tiles[dst:x()][dst:y()]) then
        return
      end

      for _, e in ipairs(self.entities) do
        if dst == e:pos() then
          entity:collide(e)
          return
        end
      end

      pos:set_x(dst:x())
      pos:set_y(dst:y())
    end

    function Class:log(value)
      local entry = "> " .. tostring(value)
      for line in entry:gmatch("[^\r\n]+") do
        while line:len() > LOG_SIZE:x() do
          table.insert(self.loglines, line:sub(1, LOG_SIZE:x()))
          line = " " .. line:sub(LOG_SIZE:x() + 1)
        end
        table.insert(self.loglines, line)
      end

      while #self.loglines > LOG_SIZE:y() do
        table.remove(self.loglines, 1)
      end
    end

    function Class:delete_entity(e)
      if e == self._hero then
        termfx.shutdown()
        print("Player died!")
        os.exit()
      end

      for i = 1, #self.entities do
        if self.entities[i] == e then
          table.remove(self.entities, i)
          break
        end
      end
    end

    function Class:hero()
      return self._hero
    end

    function Class:monsters()
      local monsters = {}
      for _, e in ipairs(self.entities) do
        if Monster:is(e) then
          table.insert(monsters, e)
        end
      end
      return monsters
    end

    function Class:window_size()
      return Point:new(MAP_SIZE:x() + LOG_SIZE:x() + 3,
                       MAP_SIZE:y() + 2)
    end

    function Class:handle_input(evt)
      if #evt.char == 0 then
        local key = evt.key
        if key == termfx.key.ARROW_UP or key == termfx.key.ARROW_DOWN or
          key == termfx.key.ARROW_LEFT or key == termfx.key.ARROW_RIGHT or
          key == termfx.key.TAB
        then
          -- Move hero if arrow keys are sent
          local dirx = 0
          local diry = 0
          if key == termfx.key.ARROW_UP then
            diry = -1
          elseif key == termfx.key.ARROW_DOWN then
            diry = 1
          elseif key == termfx.key.ARROW_LEFT then
            dirx = -1
          elseif key == termfx.key.ARROW_RIGHT then
            dirx = 1
          end

          if dirx ~= 0 or diry ~= 0 then
            self:try_move(self._hero, Point:new(dirx, diry))
            self.lights[1]:set_pos(self._hero:pos())
          end

          for _, e in ipairs(self.entities) do
            e:think()
          end
        elseif key == termfx.key.ENTER then
          -- Output the input line to log
          self:run_command(self.input)
          self.input = ""
        elseif key == termfx.key.BACKSPACE2 then
          if self.input:len() > 0 then
            self.input = self.input:sub(1, self.input:len() - 1)
          end
        else
          -- Add typed character to the stored input
          self.input = self.input .. string.char(key)
        end
      else
        self.input = self.input .. evt.char
      end
    end

    function Class:run_command(input)
      local parts = {}
      for part in string.gmatch(input, "%S+") do
        table.insert(parts, part)
      end

      local command = parts[1]
      if command == "lights" then
        local arg = parts[2]
        self.lights_on = arg == "on"
      end
    end

    function Class:random_floor()
      return self.floors[_G.game_random:random(#self.floors)]
    end


    function Class:draw()
      -- Draw a frame.
      termfx.clear()
      local window_size = self:window_size()
      termfx.rect(MAP_SIZE:x() + 2, 1, 1, window_size:y(), "│")
      termfx.rect(1, 1, window_size:x(), 1, "─")
      termfx.rect(1, 1, 1, window_size:y(), "│")
      termfx.rect(window_size:x(), 1, 1, window_size:y(), "│")
      termfx.rect(1, window_size:y(), window_size:x(), 1, "─")
      termfx.setcell(1, 1, "┌")
      termfx.setcell(window_size:x(), 1, "┐")
      termfx.setcell(1, window_size:y(), "└")
      termfx.setcell(window_size:x(), window_size:y(), "┘")
      termfx.rect(MAP_SIZE:x() + 3, 2, LOG_SIZE:x(), LOG_SIZE:y(), " ")

      -- Draw input
      termfx.printat(MAP_SIZE:x() + 3, MAP_SIZE:y() + 1, "command: " .. self.input)

      -- Draw log
      for i, line in ipairs(self.loglines) do
        termfx.printat(MAP_SIZE:x() + 3, 1 + i, line)
      end

      -- Draw map
      local intensities = {}
      for i = 1, #self.tiles do
        intensities[i] = {}
        for j = 1, #self.tiles[1] do
          intensities[i][j] = 0
        end
      end

      local visible = self._hero:visible_tiles()

      -- Mark visible tiles as seen.
      for _, t in ipairs(visible) do self.tiles[t:x()][t:y()].seen = true end

      -- Figure out every tile where light touches
      for _, light in ipairs(self.lights) do
        for _, p in ipairs(light:visible_tiles()) do
          local dist = light:pos():dist(p)
          local modifier = light:intensity()
          intensities[p:x()][p:y()] = math.min(
            intensities[p:x()][p:y()] +
              modifier * math.max((10.0 - dist) / 10.0, 0.0),
            1.0)
        end
      end

      -- Clear the board
      for i = 1, MAP_SIZE:x() do
        for j = 1, MAP_SIZE:y() do
          termfx.setcell(i + 1, j + 1, ' ', termfx.grey2color(2), BG)
        end
      end

      if self.lights_on then
        for i, row in ipairs(self.tiles) do
          for j, col in ipairs(row) do
            termfx.setcell(i+1, j+1, col:char(), termfx.grey2color(23), BG)
          end
        end

        for _, e in ipairs(self.entities) do
          if not Light:is(e) then
            local p = e:pos()
            termfx.setcell(p:x()+1, p:y()+1, e:char(), e:color(), termfx.grey2color(8))
          end
        end
      else
        -- Draw seen tiles as outline.
        for i, row in ipairs(self.tiles) do
          for j, col in ipairs(row) do
            if col.seen then
              termfx.setcell(i+1, j+1, col:seen_char(), termfx.grey2color(4), BG)
            end
          end
        end

        for _, p in ipairs(visible) do
          local c = math.floor(intensities[p:x()][p:y()] * 21 + 4)
          termfx.setcell(p:x() + 1, p:y() + 1, self.tiles[p:x()][p:y()]:char(),
                         termfx.grey2color(c), BG)
        end

        -- Draw entities
        for _, e in ipairs(self.entities) do
          if not Light:is(e) and self._hero:can_see(e) then
            local pos = e:pos()
            local c = e:compute_lighting(intensities[pos:x()][pos:y()])
            if c ~= termfx.rgb2color(0,0,0) then
              termfx.setcell(pos:x()+1, pos:y()+1, e:char(), c, termfx.grey2color(8))
            end
          end
        end
      end

      termfx.present()
    end
end, {
    loglines = types.List(types.String),
    tiles = types.List(types.List(tiles.Tile)),
    floors = types.List(tiles.GroundTile),
    input = types.String,
    _hero = Hero,
    lights_on = types.Boolean,
    entities = types.Table(types.Number, Entity),
    lights = types.Table(types.Number, Light),
})

return Game
