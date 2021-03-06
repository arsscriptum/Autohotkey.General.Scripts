/*
    πΈπππβππππΌπ πΈββππβπΈπππβ
    ---------------------------
    
    ββ―βπππΆπ β°πππβ―πππΎβ΄π π―β―ππβ―π: 
        π πππΆππ π»πβ΄ππ-β―ππΉ πβ΄ πβ―ππ ββ―βπππΆπ β°πππβ―πππΎβ΄ππ.
        π―π½β― πβ―πππππ πππΉπΆπβ― πΎπ πβ―πΆπππΎπβ― πΆππΉ πΆππ πβ―πππΎπβ β΄π β―πππβ―πππΎβ΄π
        β―ππβ΄ππ πΆπβ― π½πΎβπ½ππΎβπ½πβ―πΉ πΎπ πβ―πΉ.

    π‘π π¦πππππΊπππΎ π―ππΊπππΎ <ππππππΊπππΎπππΊπππΎ.ππΌ@πππΊππ.πΌππ>
*/

; AutoeExecute
    #NoEnv
    #SingleInstance force

    gosub MakeGui
    gosub UpdateMatch
    gosub UpdateReplace
    Gui Show, , Regex Tester
return

#IfWinActive Regex Tester
!c::
    Gui Submit, NoHide
    ClipBoard := (TabSelection = "RegExMatch") ? mNeedle : rNeedle
    MsgBox, 64, RegEx Copied, %Clipboard% has been copied to the Clipboard, 3
return

GuiEscape:
GuiClose:
    ExitApp
return

; This is called any time any of the edit boxes on the RegExMatch tab are changed.
UpdateMatch:
    Gui Submit, NoHide
    
    if not IsInteger(mStartPos) {
        mStartPos := 1
        Gui Font, cRed 
        GuiControl Font, mStartPos
    }
    else {
        Gui Font, cDefault
        GuiControl Font, mStartPos
    }
    
    ; Set Needle to return an object
    mNeedle := RegExReplace(mNeedle, "^([\w``]+?)\)", "O$1)", cnt)
    if !cnt {
        mNeedle := "O)" mNeedle
    }
    mNeedle := RegExReplace(mNeedle, """""", """")
    FoundPos := RegExMatch(ReplaceSpecChar(mHaystack), ReplaceSpecChar(mNeedle), Match, mStartPos)
    if (ErrorLevel) {
        Gui Font, cRed 
        GuiControl Font, mNeedle
    }
    else {
        Gui Font, cDefault
        GuiControl Font, mNeedle
    }
    
    ResultText := "FoundPos: " FoundPos "`n"
    ResultText .= "Match: " Match.Value() "`n"
    Loop % Match.Count() {
        ResultText .= "Match["
        ResultText .= (Match.Name[A_Index] = "") 
                    ? A_Index 
                    :  Match.Name[A_Index] 
        ResultText .= "]: " Match[A_Index] "`n"
    }
    GuiControl, , mResult, %ResultText%
return

; This is called any time any of the edit boxes on the RegExReplace tab are changed.
UpdateReplace:
    Gui Submit, NoHide
    
    if not IsInteger(rStartPos) {
        rStartPos := 1
        Gui Font, cRed 
        GuiControl Font, rStartPos
    }
    else {
        Gui Font, cDefault
        GuiControl Font, rStartPos
    }
    
    if not IsInteger(rLimit) {
        rLimit := -1
        Gui Font, cRed 
        GuiControl Font, rLimit
    }
    else {
        Gui Font, cDefault
        GuiControl Font, rLimit
    }
    rNeedle := RegExReplace(rNeedle, """""", """")
    NewStr := RegExReplace(ReplaceSpecChar(rHaystack), ReplaceSpecChar(rNeedle), rReplacement, rCount, rLimit, rStartPos)
    if (ErrorLevel) {
        Gui Font, cRed 
        GuiControl Font, rNeedle
    }
    else {
        Gui Font, cDefault
        GuiControl Font, rNeedle
    }
    
    ResultText := "Count: " rCount "`n"
    ResultText .= "NewStr: `n" NewStr "`n"
    
    GuiControl, , rResult, %ResultText%
return

MakeGui:
    Gui Font, s10, Consolas
    Gui Add, Tab2, r25 w400 vTabSelection, RegexMatch|RegexReplace
    
    Gui Tab, RegexMatch
        Gui Add, Text, , Text to be searched:
        Gui Add, Edit, r12 w370 vmHaystack gUpdateMatch
        Gui Add, Text, Section, Regular Expression:
        Gui Add, Edit, r2 w275 vmNeedle gUpdateMatch
        Gui Add, Text, x+15 ys, Start: (1)
        Gui Add, Edit, r1 w75 vmStartPos gUpdateMatch, 1
        Gui Add, Text, xs, Results:
        Gui Add, Edit, r14 w370 +readonly -TabStop vmResult
        
    Gui Tab, RegexReplace
        Gui Add, Text, , Text to be searched:
        Gui Add, Edit, r10 w370 vrHaystack gUpdateReplace
        Gui Add, Text, w275 Section, Regular Expression:
        Gui Add, Edit, r2 w275 vrNeedle gUpdateReplace
        Gui Add, Text, , Replacement Text:
        Gui Add, Edit, r2 w275 vrReplacement gUpdatereplace
        Gui Add, Text, , Results:
        Gui Add, Edit, r12 w370 +readonly -TabStop vrResult
        Gui Add, Text, ys xs+290 Section, Start: (1)
        Gui Add, Edit, r1 w75 vrStartPos gUpdateReplace, 1
        Gui Add, Text, xs y+35 , Limit: (-1)
        Gui Add, Edit, r1 w75 vrLimit gUpdateReplace, -1
return

IsInteger(str) {
    if str is integer
        return true
    else
        return false
}

ReplaceSpecChar(text, mode := false) {
   if mode {
      for k, v in [["a", "`a"], ["n", "`n"], ["r", "`r"], ["t", "`t"]] {
         if InStr(text, v[1])
            Return v[2]
      }
   }
   else {
      while RegExMatch(text, "sO)(.*?(?<!``)(?:````)*)(``[anrt]|$)", m, m ? m.Pos + m.Len : 1) {
         if (m[0] = "")
            break
         else
            newText .= m[1] . ReplaceSpecChar(m[2], true)
      }
      Return newText
   }
}