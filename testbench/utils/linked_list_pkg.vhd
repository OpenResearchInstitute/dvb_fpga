--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This file is part of the DVB IP.
--
-- DVB IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB IP.  If not, see <http://www.gnu.org/licenses/>.

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library str_format;
use str_format.str_format_pkg.all;

package linked_list_pkg is
  generic (type type_t);

  -- To iterate
  type array_t is array (natural range <>) of type_t;

  -- Create the linked list core record and a pointer to it
  type link_t;
  type ptr_t is access link_t;
  type link_t is record
    content  : type_t;
    next_ptr : ptr_t;
  end record;

  -- Linked list core API
  type linked_list_t is protected
    procedure append (variable item : inout type_t);
    impure function pop return type_t;
    impure function get(index : natural) return type_t;
    impure function items return array_t;
    impure function size return integer;
    impure function empty return boolean;
  end protected;

end linked_list_pkg;

package body linked_list_pkg is

  type linked_list_t is protected body
    variable m_head   : ptr_t := null;
    variable m_tail   : ptr_t := null;
    variable m_size   : natural := 0;
    constant m_logger : logger_t := get_logger("linked_list_logger");

    procedure append (variable item : inout type_t) is
      variable ptr : ptr_t;
    begin
      ptr := new link_t;
      ptr.content := item;

      if m_tail /= null then
        m_tail.next_ptr := ptr;
      end if;

      m_tail := ptr;

      if m_head = null then
        m_head := m_tail;
      end if;

      --trace(m_logger, sformat("List size: %d -> %d", fo(m_size), fo(m_size + 1)));
      m_size := m_size + 1;
      
    end;

    impure function pop return type_t is
      variable item : type_t;
      variable next_head : ptr_t;
    begin
      -- --trace(m_logger, sformat("List size: %d, head: %s", fo(m_size), fo(m_head = null)));
      assert m_head /= null and m_size /= 0
        report "List is empty"
        severity Failure;

      -- --trace(m_logger, "Assigning item");
      item := m_head.content;
      -- --trace(m_logger, "saving next head");
      next_head := m_head.next_ptr;
      -- --trace(m_logger, "Deallocating head");
      -- deallocate(m_head);
      -- --trace(m_logger, "Assigning next head");
      m_head := next_head;

      --trace(m_logger, sformat("List size: %d -> %d", fo(m_size), fo(m_size - 1)));
      m_size := m_size - 1;
      -- --trace(m_logger, sformat("List now has %d items", fo(m_size)));


      return item;

    end;

    impure function get(index : natural) return type_t is
      variable current : ptr_t;
    begin
      current := m_head;

      for i in 0 to index - 1 loop
        current := current.next_ptr;
      end loop;

      return current.content;
    end;

    impure function items return array_t is
      variable list    : array_t(0 to m_size - 1);
      variable current : ptr_t;
    begin
      if m_size = 0 then
        return list;
      end if;

      current := m_head;

      for i in 0 to m_size - 1 loop
        list(i) := current.content;
        current := current.next_ptr;
      end loop;

      return list;
    end;

    impure function empty return boolean is
    begin
      return m_size = 0;
    end;

    impure function size return integer is
    begin
      return m_size;
    end;

  end protected body;

end package body;
