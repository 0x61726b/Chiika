#----------------------------------------------------------------------------
#Chiika
#Copyright (C) 2016 arkenthera
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 23.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

DefaultOptions = {
  RefreshUponLaunch: true,
  AnimeListColumns:[
    {column: { name:"typeWithIcon",order:0,toggleable:true,hiddenDefault:false} },
    {column: { name:"title",order:1,toggleable:false,hiddenDefault:false} },
    {column: { name:"score",order:2,toggleable:false,hiddenDefault:false} },
    {column: { name:"season",order:4,toggleable:false,hiddenDefault:false }},
    {column: { name:"progress",order:3,toggleable:false,hiddenDefault:false }},
    {column: { name:"typeWithIconColors",order:-1,toggleable:true,hiddenDefault:true }},
    {column: { name:"typeWithText",order:-1,toggleable:true,hiddenDefault:true }},
    {column: { name:"airingStatusText",order:-1,toggleable:true,hiddenDefault:true }},
  ]
}

module.exports = DefaultOptions
