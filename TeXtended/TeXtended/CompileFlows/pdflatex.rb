#!/usr/bin/env ruby
# Arguments:
# 0.    <file-to-compile>               The path to the typesettable document
# 1.    <output-pdf-path>               Path to the output pdf file
# 2.    <iteration>                     The number of reruns of the typesetter
# 3.    <compile-mode>                  The compile mode (live = 0, draft = 1, final = 2)
# 4.    <compile bib>                   If 1, bibliography should be compiled at the end of the first run.
# 5.    <string-of-custom-arguments>    A string containing multiple custom arguments (usually seperated by space)

# ========================================================================
# === Initialization. Don't change the code between the lines of "="'s ===
# ========================================================================
require 'fileutils'
argCount = ARGV.count
if argCount < 2
    puts "Too few arguments: usage: <file-to-compile> <output-pdf-path> (<iterations> <compile-mode> <compile bib> \"<string-of-custom-arguments>\")"
    exit
end

class Mode
        LIVE = 0
        DRAFT = 1
        FINAL = 2
    
    def self.to_s(mode)
         case mode
            when LIVE
                return "LIVE"
            when DRAFT
                return "DRAFT"
            when FINAL
                return "FINAL"
             else
                return "UNKNOWN"
         end
    end
end
# Initializing the variables:
texPath         = ARGV[0]
pdfPath         = ARGV[1]
iterations      = argCount >= 3 ? ARGV[2].to_i : 1
mode            = argCount >= 4 ? ARGV[3].to_i : 0
compileBib      = argCount >= 5 ? ARGV[4].to_i : 0
customArguments = argCount >= 6 ? ARGV[5].split : []

pdfName         = File.basename(pdfPath, File.extname(pdfPath))
outputDir       = File.dirname(pdfPath)
FileUtils.cd(outputDir)

# ========================================================================
# =============== You'd like to change to code from here: ================
# ========================================================================

TYPESETTER      = "/usr/texbin/pdflatex"
BIBTEX          ="/usr/texbin/bibtex"
ENV['PATH']     ="/usr/texbin:/usr/local/bin:#{ENV['PATH']}"

puts "==========================================================="
puts "\t Typesetting #{texPath}"
puts "\t Output Path:\t\t #{pdfPath}"
puts "\t Iterations:\t\t #{iterations}" unless argCount < 3
puts "\t Compile bib:\t\t #{(compileBib > 0? 'YES' : 'NO')}" unless argCount < 5
puts "\t Custom parameter:\t #{customArguments}" unless argCount < 6
puts "\t Compile Mode:\t\t #{Mode::to_s(mode)}" unless argCount < 4
puts "==========================================================="


for iteration in 1..iterations do
    puts "==========================================================="
    puts "\t Iteration #{iteration} ..."
    puts "-----------------------------------------------------------"
    case mode
        when Mode::LIVE
        system("#{TYPESETTER} -synctex=1 -file-line-error -interaction nonstopmode -output-directory=\"#{outputDir}\" -jobname=\"#{pdfName}\" \"#{texPath}\"")
        
        when Mode::DRAFT
        system("#{TYPESETTER} -synctex=1 -file-line-error -output-directory=\"#{outputDir}\" -jobname=\"#{pdfName}\" \"#{texPath}\"")
        
        when Mode::FINAL
        system({"TMPDIR" => outputDir}, "#{TYPESETTER} -synctex=1 -file-line-error -output-directory=\"#{outputDir}\" -jobname=\"#{pdfName}\" \"#{texPath}\"")
        
        else
        puts "ERROR: Unknown compile mode!!"
    end
    
    # Compile the bibliography:
    if iteration == 1 && compileBib > 0
        puts "-------------------------------------------------------"
        system("export TMPDIR=\"outputDir\" && #{BIBTEX} \"#{pdfName}\"")
    end
    puts "\n"
end
puts "==========================================================="
puts "==== pdflatex has completed the typesetting procedure! ===="
puts "==========================================================="