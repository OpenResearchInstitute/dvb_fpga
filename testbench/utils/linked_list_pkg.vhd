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
    data     : type_t;
    next_ptr : ptr_t;
  end record;

  -- Linked list core API
  type linked_list_t is protected
    procedure push_back (variable item : inout type_t);
    impure function pop_front return type_t;
    impure function get(index : natural) return type_t;
    impure function items return array_t;
    impure function size return integer;
    impure function empty return boolean;
    procedure reset;
  end protected;

end linked_list_pkg;

package body linked_list_pkg is

  type linked_list_t is protected body
    variable m_head   : ptr_t := null;
    variable m_tail   : ptr_t := null;
    variable m_size   : natural := 0;
    constant m_logger : logger_t := get_logger("linked_list_logger");

    procedure push_back (variable item : inout type_t) is
      variable new_item : ptr_t;
      variable node     : ptr_t;
    begin
      new_item      := new link_t;
      new_item.data := item;

      if m_head = null then
        m_head        := new_item;
      else
        node          := m_head;
        node.next_ptr := new_item;
        m_head        := m_head.next_ptr;
      end if;

      if m_tail = null and m_size = 0 then
        m_tail := m_head;
      end if;

      m_size := m_size + 1;
      
    end;

    impure function pop_front return type_t is
      variable node : ptr_t;
      variable item : type_t;
    begin
      assert m_tail /= null and m_size /= 0
        report "List is empty"
        severity Failure;

      node   := m_tail;
      m_tail := m_tail.next_ptr;
      item   := node.data;
      deallocate(node);

      m_size    := m_size - 1;

      return item;

    end;

    impure function get(index : natural) return type_t is
      variable current : ptr_t;
    begin
      current := m_tail;

      for i in 0 to index - 1 loop
        current := current.next_ptr;
      end loop;

      return current.data;
    end;

    impure function items return array_t is
      variable list    : array_t(0 to m_size - 1);
      variable current : ptr_t;
    begin
      if m_size = 0 then
        return list;
      end if;

      current := m_tail;

      for i in 0 to m_size - 1 loop
        list(i) := current.data;
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

    procedure reset is
    begin
      m_size := 0;
      m_head := null;
      m_tail := null;
    end;

  end protected body;

end package body;
